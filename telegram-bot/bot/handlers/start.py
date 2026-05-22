"""
/start command handler
"""
from aiogram import Router
from aiogram.filters import CommandStart
from aiogram.types import Message
from bot.keyboards.reply import get_phone_keyboard
import logging

logger = logging.getLogger(__name__)
router = Router()


@router.message(CommandStart())
async def cmd_start(message: Message):
    await message.answer(
        f"👋 Salom, <b>{message.from_user.first_name}</b>!\n\n"
        f"🔐 Ro'yxatdan o'tish uchun telefon raqamingizni yuboring.",
        reply_markup=get_phone_keyboard(),
        parse_mode="HTML"
    )
