"""
Orders CRUD
"""
from fastapi import APIRouter, Depends, HTTPException, Header, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.db.models.order import Order
from app.db.models.user import User
from app.services.auth_service import AuthService
from app.core.exceptions import AuthError
from app.schemas.auth import OrderCreateRequest, OrderResponse, OrderStatusUpdate
from typing import List
import logging

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
    stmt = select(Order).where(Order.status == "pending").order_by(Order.created_at.desc())
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
        stmt = select(Order).where(Order.yukchi_id == user.id).order_by(Order.created_at.desc())
    else:
        stmt = select(Order).where(Order.furachi_id == user.id).order_by(Order.created_at.desc())
    result = await db.execute(stmt)
    return result.scalars().all()


@router.patch("/{order_id}/accept", response_model=OrderResponse)
async def accept_order(
    order_id: int,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Furachi — buyurtmani qabul qilish"""
    user = await get_user(authorization, db)
    if user.role != "furachi":
        raise HTTPException(status_code=403, detail="Faqat furachilар qabul qiladi")

    stmt = select(Order).where(Order.id == order_id, Order.status == "pending")
    result = await db.execute(stmt)
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Buyurtma topilmadi")

    order.furachi_id = user.id
    order.status = "accepted"
    await db.commit()
    await db.refresh(order)
    return order


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
    await db.refresh(order)
    return order
