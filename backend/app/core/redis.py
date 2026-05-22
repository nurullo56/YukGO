"""
Redis - real Redis bo'lmasa in-memory fallback ishlatadi
"""
import time
import os
from typing import Optional

_store: dict = {}
_expiry: dict = {}


class FakeRedis:
    async def setex(self, key: str, ttl: int, value: str):
        _store[key] = value
        _expiry[key] = time.time() + ttl

    async def get(self, key: str) -> Optional[str]:
        if key not in _store:
            return None
        if time.time() > _expiry.get(key, float('inf')):
            del _store[key]
            return None
        return _store[key]

    async def delete(self, key: str):
        _store.pop(key, None)
        _expiry.pop(key, None)

    async def aclose(self):
        pass


_redis_instance: Optional[FakeRedis] = None


async def get_redis() -> FakeRedis:
    global _redis_instance
    if _redis_instance is None:
        _redis_instance = FakeRedis()
    return _redis_instance


async def close_redis():
    global _redis_instance
    _redis_instance = None
