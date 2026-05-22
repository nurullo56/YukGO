"""
Logging middleware
"""
from typing import Callable, Dict, Any, Awaitable
from aiogram import BaseMiddleware
from aiogram.types import Message, TelegramObject
import logging

logger = logging.getLogger(__name__)


class LoggingMiddleware(BaseMiddleware):
    """
    Barcha messagelarni log qilish
    """
    
    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any]
    ) -> Any:
        # Message bo'lsa log qilish
        if isinstance(event, Message):
            user = event.from_user
            logger.info(
                f"📨 Message from {user.id} (@{user.username}): {event.text[:50] if event.text else 'NO_TEXT'}"
            )
        
        # Handler'ni chaqirish
        return await handler(event, data)