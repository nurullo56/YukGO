"""
Redis-based token storage
"""
from typing import Optional
import redis.asyncio as redis
from bot.config import settings
import logging

logger = logging.getLogger(__name__)

_redis_pool: Optional[redis.Redis] = None


async def get_redis() -> redis.Redis:
    """Redis connection pool"""
    global _redis_pool
    if _redis_pool is None:
        # Docker ichida redis service nomi: redis
        redis_url = "redis://logistic_redis:6379/1"  # DB 1 for bot (backend uses 0)
        _redis_pool = redis.from_url(
            redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=5
        )
        logger.info("✅ Redis pool initialized")
    return _redis_pool


async def save_token(user_id: int, token: str, ttl: int = 300):
    """Token'ni saqlash (5 minut default)"""
    r = await get_redis()
    await r.setex(f"bot:token:{user_id}", ttl, token)


async def get_token(user_id: int) -> Optional[str]:
    """Token'ni olish"""
    r = await get_redis()
    return await r.get(f"bot:token:{user_id}")


async def delete_token(user_id: int):
    """Token'ni o'chirish"""
    r = await get_redis()
    await r.delete(f"bot:token:{user_id}")


async def close_redis():
    """Redis pool'ni yopish"""
    global _redis_pool
    if _redis_pool:
        await _redis_pool.aclose()
        _redis_pool = None