"""
Chat: WebSocket real-time + REST history
"""
import json
import logging
from datetime import datetime, timezone
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Header, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db, async_session_maker
from app.db.models.message import Message
from app.db.models.user import User
from app.services.auth_service import AuthService
from app.services.fcm import send_push
from app.core.exceptions import AuthError

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/chat", tags=["chat"])


# ─── Connection Manager ──────────────────────────────────────────────────────

class ConnectionManager:
    def __init__(self):
        # room_id → {user_id: WebSocket}
        self._rooms: dict[str, dict[int, WebSocket]] = {}

    async def connect(self, room_id: str, user_id: int, ws: WebSocket):
        await ws.accept()
        self._rooms.setdefault(room_id, {})[user_id] = ws

    def disconnect(self, room_id: str, user_id: int):
        room = self._rooms.get(room_id, {})
        room.pop(user_id, None)
        if not room:
            self._rooms.pop(room_id, None)

    async def broadcast(self, room_id: str, message: dict, exclude_user: int | None = None):
        room = self._rooms.get(room_id, {})
        dead = []
        for uid, ws in room.items():
            if uid == exclude_user:
                continue
            try:
                await ws.send_json(message)
            except Exception:
                dead.append(uid)
        for uid in dead:
            room.pop(uid, None)

    def online_users(self, room_id: str) -> set[int]:
        return set(self._rooms.get(room_id, {}).keys())


manager = ConnectionManager()


# ─── WebSocket endpoint ───────────────────────────────────────────────────────

@router.websocket("/ws/{room_id}")
async def chat_ws(
    room_id: str,
    websocket: WebSocket,
    token: str = Query(...),
):
    # Authenticate (qisqa muddatli session — pool ni band qilmaymiz)
    async with async_session_maker() as db:
        try:
            user: User = await AuthService.get_current_user(token, db)
        except AuthError:
            await websocket.close(code=4001)
            return

    await manager.connect(room_id, user.id, websocket)
    logger.info(f"WS connected: user={user.id} room={room_id}")

    # Send last 50 messages on connect
    async with async_session_maker() as db:
        history = await _get_history(room_id, db, limit=50)
    await websocket.send_json({"type": "history", "messages": history})

    try:
        while True:
            raw = await websocket.receive_text()
            data = json.loads(raw)
            content = (data.get("content") or "").strip()
            if not content:
                continue

            # Har bir xabar uchun yangi qisqa session
            async with async_session_maker() as db:
                msg = Message(room_id=room_id, sender_id=user.id, content=content)
                db.add(msg)
                await db.commit()
                await db.refresh(msg)

                payload = {
                    "type": "message",
                    "id": msg.id,
                    "room_id": room_id,
                    "sender_id": user.id,
                    "sender_name": f"{user.first_name or ''} {user.last_name or ''}".strip() or "User",
                    "content": content,
                    "created_at": msg.created_at.isoformat(),
                }

                online = manager.online_users(room_id)
                await _push_to_offline(room_id, user, content, online, db)

            # Broadcast to others in room
            await manager.broadcast(room_id, payload, exclude_user=user.id)

            # Also echo back to sender
            await websocket.send_json(payload)

    except WebSocketDisconnect:
        manager.disconnect(room_id, user.id)
        logger.info(f"WS disconnected: user={user.id} room={room_id}")
    except Exception as e:
        logger.error(f"WS error: {e}")
        manager.disconnect(room_id, user.id)


# ─── REST: message history ────────────────────────────────────────────────────

@router.get("/{room_id}/messages")
async def get_messages(
    room_id: str,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")
    try:
        await AuthService.get_current_user(authorization[7:], db)
    except AuthError as e:
        raise HTTPException(status_code=401, detail=e.message)

    return await _get_history(room_id, db, limit=limit, offset=offset)


# ─── FCM token update ─────────────────────────────────────────────────────────

@router.patch("/fcm-token")
async def update_fcm_token(
    body: dict,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db),
):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")
    try:
        user: User = await AuthService.get_current_user(authorization[7:], db)
    except AuthError as e:
        raise HTTPException(status_code=401, detail=e.message)

    token = body.get("fcm_token", "")
    user.fcm_token = token
    await db.commit()
    return {"success": True}


# ─── Helpers ─────────────────────────────────────────────────────────────────

async def _get_history(room_id: str, db: AsyncSession, limit: int = 50, offset: int = 0):
    stmt = (
        select(Message)
        .where(Message.room_id == room_id)
        .order_by(Message.created_at.asc())
        .offset(offset)
        .limit(limit)
    )
    result = await db.execute(stmt)
    msgs = result.scalars().all()
    out = []
    for m in msgs:
        sender_name = ""
        if m.sender:
            sender_name = f"{m.sender.first_name or ''} {m.sender.last_name or ''}".strip()
        out.append({
            "type": "message",
            "id": m.id,
            "room_id": m.room_id,
            "sender_id": m.sender_id,
            "sender_name": sender_name or "User",
            "content": m.content,
            "created_at": m.created_at.isoformat() if m.created_at else "",
        })
    return out


async def _push_to_offline(room_id: str, sender: User, content: str, online: set[int], db: AsyncSession):
    """Offline userlarga push notification yuborish."""
    # room_id = "order_{id}" formatidan order_id olish
    if not room_id.startswith("order_"):
        return
    try:
        order_id = int(room_id.split("_", 1)[1])
    except (ValueError, IndexError):
        return

    from app.db.models.order import Order
    stmt = select(Order).where(Order.id == order_id)
    result = await db.execute(stmt)
    order = result.scalar_one_or_none()
    if not order:
        return

    # Order ga bog'liq ikki user: yukchi va furachi
    targets = [uid for uid in [order.yukchi_id, order.furachi_id]
               if uid and uid != sender.id and uid not in online]

    for uid in targets:
        stmt2 = select(User).where(User.id == uid)
        res2 = await db.execute(stmt2)
        target = res2.scalar_one_or_none()
        if target and target.fcm_token:
            sender_name = f"{sender.first_name or ''} {sender.last_name or ''}".strip() or "YukGo"
            await send_push(
                token=target.fcm_token,
                title=sender_name,
                body=content[:100],
                data={"type": "chat", "room_id": room_id, "order_id": str(order_id)},
            )
