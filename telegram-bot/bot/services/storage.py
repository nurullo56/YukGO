"""
In-memory storage — Redis o'rniga (local ishga tushirish uchun)
token: str  →  user_id: int
otp_token: str  →  {otp, phone, first_name, last_name, ...}
"""
import time
from typing import Optional

# { user_id: (token, expire_at) }
_token_store: dict[int, tuple[str, float]] = {}

# { token: (data_dict, expire_at) }
_otp_store: dict[str, tuple[dict, float]] = {}


# ─── Token ───────────────────────────────────────────────────────────────────

async def save_token(user_id: int, token: str, ttl: int = 300):
    _token_store[user_id] = (token, time.time() + ttl)


async def get_token(user_id: int) -> Optional[str]:
    entry = _token_store.get(user_id)
    if not entry:
        return None
    token, exp = entry
    if time.time() > exp:
        del _token_store[user_id]
        return None
    return token


async def delete_token(user_id: int):
    _token_store.pop(user_id, None)


# ─── OTP ─────────────────────────────────────────────────────────────────────

async def save_otp(token: str, data: dict, ttl: int = 300):
    _otp_store[token] = (data, time.time() + ttl)


async def get_otp_data(token: str) -> Optional[dict]:
    entry = _otp_store.get(token)
    if not entry:
        return None
    data, exp = entry
    if time.time() > exp:
        del _otp_store[token]
        return None
    return data


async def verify_otp(token: str, entered_otp: str) -> Optional[dict]:
    data = await get_otp_data(token)
    if not data:
        return None
    if data.get("otp") == entered_otp:
        _otp_store.pop(token, None)
        return data
    return None


# Redis bilan moslik uchun (main.py da close_redis chaqiriladi)
async def close_redis():
    pass
