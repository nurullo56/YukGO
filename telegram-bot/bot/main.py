"""
Bot runner
"""
import asyncio
import logging
from aiogram import Bot, Dispatcher
from aiogram.enums import ParseMode
from bot.config import settings
from bot.handlers import start, contact
from bot.middlewares.logging_middleware import LoggingMiddleware
from bot.services.storage import close_redis

# Logging setup
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


async def main():
    """Bot ishga tushirish"""

    bot = Bot(token=settings.BOT_TOKEN, parse_mode=ParseMode.HTML)
    
    dp = Dispatcher()
    
    # Middlewares
    dp.message.middleware(LoggingMiddleware())
    
    # Handlers
    dp.include_router(start.router)
    dp.include_router(contact.router)
    
    # Bot info
    bot_info = await bot.get_me()
    logger.info(f"🤖 Bot started: @{bot_info.username}")
    
    # Polling
    try:
        await dp.start_polling(bot, allowed_updates=dp.resolve_used_update_types())
    finally:
        await bot.session.close()
        await close_redis()
        logger.info("✅ Cleanup completed")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("👋 Bot stopped")