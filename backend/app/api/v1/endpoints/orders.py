"""
Orders CRUD
"""
from fastapi import APIRouter, Depends, HTTPException, Header, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import selectinload
from app.db.session import get_db
from app.db.models.order import Order
from app.db.models.user import User
from app.services.auth_service import AuthService
from app.core.exceptions import AuthError
from app.schemas.auth import OrderCreateRequest, OrderResponse, OrderStatusUpdate
from app.services.fcm import send_push
from typing import List
import logging
import asyncio

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/orders", tags=["orders"])


async def get_user(authorization: str, db: AsyncSession) -> User:
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")
    try:
        return await AuthService.get_current_user(authorization[7:], db)
    except AuthError as e:
        raise HTTPException(status_code=401, detail=e.message)


@router.post("", response_model=OrderResponse, status_code=201)
async def create_order(
    request: OrderCreateRequest,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Yukchi — yuk e'lon qilish"""
    user = await get_user(authorization, db)
    if user.role != "yukchi":
        raise HTTPException(status_code=403, detail="Faqat yukchilar buyurtma yaratadi")

    order = Order(
        yukchi_id=user.id,
        cargo_type=request.cargo_type,
        from_city=request.from_city,
        to_city=request.to_city,
        weight_kg=request.weight_kg,
        price=request.price,
        description=request.description,
        status="pending"
    )
    db.add(order)
    await db.commit()
    await db.refresh(order)
    return order


@router.get("", response_model=List[OrderResponse])
async def list_orders(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Barcha ochiq buyurtmalar (furachi uchun)"""
    await get_user(authorization, db)
    stmt = (select(Order)
            .options(selectinload(Order.yukchi))
            .where(Order.status == "pending")
            .order_by(Order.created_at.desc()))
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/my", response_model=List[OrderResponse])
async def my_orders(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """O'z buyurtmalarim"""
    user = await get_user(authorization, db)
    if user.role == "yukchi":
        stmt = (select(Order)
                .options(selectinload(Order.furachi))
                .where(Order.yukchi_id == user.id)
                .order_by(Order.created_at.desc()))
    else:
        stmt = (select(Order)
                .options(selectinload(Order.yukchi))
                .where(Order.furachi_id == user.id)
                .order_by(Order.created_at.desc()))
    result = await db.execute(stmt)
    return result.scalars().all()


@router.patch("/{order_id}/accept", response_model=OrderResponse)
async def accept_order(
    order_id: int,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Furachi — buyurtmani qabul qilish (atomic, race condition yo'q)"""
    user = await get_user(authorization, db)
    if user.role != "furachi":
        raise HTTPException(status_code=403, detail="Faqat furachilар qabul qiladi")

    # Atomic UPDATE: faqat status=="pending" va furachi_id==NULL bo'lganda ishlaydi
    stmt = (
        update(Order)
        .where(Order.id == order_id, Order.status == "pending", Order.furachi_id == None)
        .values(furachi_id=user.id, status="accepted")
        .execution_options(synchronize_session=False)
    )
    result = await db.execute(stmt)
    await db.commit()

    if result.rowcount == 0:
        # Nima uchun muvaffaqiyatsiz ekanini aniqlash
        check = await db.execute(select(Order).where(Order.id == order_id))
        existing = check.scalar_one_or_none()
        if not existing:
            raise HTTPException(status_code=404, detail="Buyurtma topilmadi")
        raise HTTPException(status_code=409, detail="Buyurtma allaqachon boshqa furachi tomonidan qabul qilingan")

    stmt2 = (
        select(Order)
        .options(selectinload(Order.yukchi), selectinload(Order.furachi))
        .where(Order.id == order_id)
    )
    result2 = await db.execute(stmt2)
    accepted = result2.scalar_one()

    # Yukchiga push notification yuborish
    if accepted.yukchi and accepted.yukchi.fcm_token:
        furachi_name = f"{user.first_name or ''} {user.last_name or ''}".strip() or "Furachi"
        asyncio.create_task(send_push(
            token=accepted.yukchi.fcm_token,
            title="Buyurtmangiz qabul qilindi!",
            body=f"{furachi_name} sizning buyurtmangizni qabul qildi: {accepted.from_city} → {accepted.to_city}",
            data={"order_id": str(order_id), "type": "order_accepted"},
        ))

    return accepted


@router.patch("/{order_id}/status", response_model=OrderResponse)
async def update_status(
    order_id: int,
    body: OrderStatusUpdate,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Status yangilash"""
    user = await get_user(authorization, db)
    stmt = select(Order).where(Order.id == order_id)
    result = await db.execute(stmt)
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Buyurtma topilmadi")
    if order.yukchi_id != user.id and order.furachi_id != user.id:
        raise HTTPException(status_code=403, detail="Ruxsat yo'q")

    order.status = body.status
    await db.commit()

    # Refresh with relations for FCM
    stmt3 = (select(Order).options(selectinload(Order.yukchi), selectinload(Order.furachi))
             .where(Order.id == order_id))
    result3 = await db.execute(stmt3)
    updated = result3.scalar_one()

    status_map = {
        "in_transit": "Yo'lda",
        "delivered": "Yetkazildi",
        "cancelled": "Bekor qilindi",
    }
    status_text = status_map.get(body.status, body.status)

    # Yukchiga xabar
    if updated.yukchi and updated.yukchi.fcm_token and updated.yukchi_id != user.id:
        asyncio.create_task(send_push(
            token=updated.yukchi.fcm_token,
            title=f"Buyurtma: {status_text}",
            body=f"{updated.from_city} → {updated.to_city} buyurtmasi holati yangilandi",
            data={"order_id": str(order_id), "type": "status_update", "status": body.status},
        ))

    # Furachiga xabar
    if updated.furachi and updated.furachi.fcm_token and updated.furachi_id != user.id:
        asyncio.create_task(send_push(
            token=updated.furachi.fcm_token,
            title=f"Buyurtma: {status_text}",
            body=f"{updated.from_city} → {updated.to_city} buyurtmasi holati yangilandi",
            data={"order_id": str(order_id), "type": "status_update", "status": body.status},
        ))

    return updated
