"""
Admin panel API endpointlari
"""
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from app.db.session import get_db
from app.db.models.user import User
from app.db.models.order import Order
from app.config import settings
from typing import Optional
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/admin", tags=["admin"])


def verify_admin(x_admin_key: str = Header(...)):
    if x_admin_key != settings.ADMIN_SECRET:
        raise HTTPException(status_code=403, detail="Admin ruxsati yo'q")


@router.get("/stats")
async def get_stats(db: AsyncSession = Depends(get_db), _=Depends(verify_admin)):
    total_users    = (await db.execute(select(func.count(User.id)))).scalar() or 0
    yukchis        = (await db.execute(select(func.count(User.id)).where(User.role == 'yukchi'))).scalar() or 0
    furachis       = (await db.execute(select(func.count(User.id)).where(User.role == 'furachi'))).scalar() or 0
    total_orders   = (await db.execute(select(func.count(Order.id)))).scalar() or 0
    active_orders  = (await db.execute(
        select(func.count(Order.id)).where(Order.status.in_(['pending', 'accepted', 'in_transit']))
    )).scalar() or 0
    delivered      = (await db.execute(select(func.count(Order.id)).where(Order.status == 'delivered'))).scalar() or 0
    cancelled      = (await db.execute(select(func.count(Order.id)).where(Order.status == 'cancelled'))).scalar() or 0

    return {
        "total_users":     total_users,
        "yukchis":         yukchis,
        "furachis":        furachis,
        "total_orders":    total_orders,
        "active_orders":   active_orders,
        "delivered_orders": delivered,
        "cancelled_orders": cancelled,
    }


@router.get("/users")
async def get_users(
    role: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(verify_admin),
):
    stmt = select(User).order_by(User.created_at.desc())
    if role:
        stmt = stmt.where(User.role == role)
    result = await db.execute(stmt)
    users = result.scalars().all()
    return [
        {
            "id":                 u.id,
            "first_name":         u.first_name or "",
            "last_name":          u.last_name or "",
            "phone":              u.phone,
            "role":               u.role,
            "is_profile_complete": u.is_profile_complete,
            "is_active":          u.is_active,
            "truck_type":         u.truck_type,
            "from_city":          u.from_city,
            "created_at":         u.created_at.isoformat() if u.created_at else None,
        }
        for u in users
    ]


@router.get("/orders")
async def get_orders(
    status: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(verify_admin),
):
    stmt = (
        select(Order)
        .options(selectinload(Order.yukchi), selectinload(Order.furachi))
        .order_by(Order.created_at.desc())
    )
    if status:
        stmt = stmt.where(Order.status == status)
    result = await db.execute(stmt)
    orders = result.scalars().all()
    return [
        {
            "id":         o.id,
            "from_city":  o.from_city,
            "to_city":    o.to_city,
            "cargo_type": o.cargo_type,
            "weight_kg":  o.weight_kg,
            "price":      o.price,
            "status":     o.status,
            "created_at": o.created_at.isoformat() if o.created_at else None,
            "yukchi": {
                "id":    o.yukchi.id,
                "name":  f"{o.yukchi.first_name or ''} {o.yukchi.last_name or ''}".strip(),
                "phone": o.yukchi.phone,
            } if o.yukchi else None,
            "furachi": {
                "id":    o.furachi.id,
                "name":  f"{o.furachi.first_name or ''} {o.furachi.last_name or ''}".strip(),
                "phone": o.furachi.phone,
            } if o.furachi else None,
        }
        for o in orders
    ]


@router.patch("/orders/{order_id}/status")
async def update_order_status(
    order_id: int,
    body: dict,
    db: AsyncSession = Depends(get_db),
    _=Depends(verify_admin),
):
    result = await db.execute(select(Order).where(Order.id == order_id))
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Buyurtma topilmadi")
    new_status = body.get("status")
    if new_status:
        order.status = new_status
        await db.commit()
    return {"ok": True, "status": order.status}


@router.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    _=Depends(verify_admin),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")
    user.is_active = False
    await db.commit()
    return {"ok": True}
