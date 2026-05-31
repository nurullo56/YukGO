"""
Redis — production'da haqiqiy Redis, development'da in-memory fallback
"""
import time
from typing import Optional

# ── In-memory fallback (development only) ────────────────────────────────────

_store: dict = {}
_expiry: dict = {}


class FakeRedis:
    """Development uchun in-memory Redis mock. Production'da ISHLATMANG!"""

    async def setex(self, key: str, ttl: int, value: str):
        _store[key] = value
        _expiry[key] = time.time() + ttl

    async def get(self, key: str) -> Optional[str]:
        if key not in _store:
            return None
        if time.time() > _expiry.get(key, float("inf")):
            _store.pop(key, None)
            _expiry.pop(key, None)
            return None
        return _store[key]

    async def delete(self, key: str):
        _store.pop(key, None)
        _expiry.pop(key, None)

    async def incr(self, key: str) -> int:
        val = int(_store.get(key, "0")) + 1
        _store[key] = str(val)
        return val

    async def expire(self, key: str, ttl: int):
        if key in _store:
            _expiry[key] = time.time() + ttl

    async def aclose(self):
        pass


# ── Real Redis (production) ──────────────────────────────────────────────────

_redis_instance = None


async def get_redis():
    global _redis_instance
    if _redis_instance is not None:
        return _redis_instance

    from app.config import settings

    if settings.REDIS_URL and settings.REDIS_URL.startswith("redis"):
        try:
            from redis.asyncio import Redis
            client = Redis.from_url(settings.REDIS_URL, decode_responses=True)
            await client.ping()
            _redis_instance = client
            return _redis_instance
        except Exception:
            pass  # Redis yo'q — fallback ishlatiladi

    _redis_instance = FakeRedis()
    return _redis_instance


async def close_redis():
    global _redis_instance
    if _redis_instance and not isinstance(_redis_instance, FakeRedis):
        await _redis_instance.aclose()
    _redis_instance = None
