"""
Contact handler — telefon oladi, backend'ga yuboradi, kod ko'rsatadi
"""
import aiohttp
from aiogram import Router, F
from aiogram.types import Message
from bot.utils.validators import normalize_phone
from bot.keyboards.reply import remove_keyboard
from bot.config import settings
import logging

logger = logging.getLogger(__name__)
router = Router()


@router.message(F.contact)
async def handle_contact(message: Message):
    user_id = message.from_user.id

    if message.contact.user_id != user_id:
        await message.answer(
            "❌ Iltimos, faqat <b>o'z</b> telefon raqamingizni yuboring!",
            parse_mode="HTML"
        )
        return

    phone = normalize_phone(message.contact.phone_number)
    processing = await message.answer("⏳ Tekshirilmoqda...")

    try:
        async with aiohttp.ClientSession() as session:
            payload = {
                "telegram_id": user_id,
                "phone": phone,
                "first_name": message.from_user.first_name or "",
                "last_name": message.from_user.last_name or "",
                "username": message.from_user.username or "",
            }
            async with session.post(
                f"{settings.BACKEND_URL}/api/v1/auth/phone-login",
                json=payload,
                timeout=aiohttp.ClientTimeout(total=15)
            ) as resp:
                data = await resp.json()

        await processing.delete()

        if resp.status == 200:
            code = data["code"]
            await message.answer(
                f"✅ <b>Tekshirildi!</b>\n\n"
                f"📱 Raqam: <code>{phone}</code>\n\n"
                f"🔐 Ilovadagi tasdiqlash kodi:\n\n"
                f"<code>{code}</code>\n\n"
                f"⚠️ Ushbu kod 5 daqiqa amal qiladi.\n"
                f"Ilovaga qayting va shu kodni kiriting.",
                reply_markup=remove_keyboard(),
                parse_mode="HTML"
            )
            logger.info(f"✅ User {user_id} got code: {code}")
        else:
            await message.answer(
                "❌ Xatolik yuz berdi. Qaytadan urinib ko'ring.",
                reply_markup=remove_keyboard()
            )

    except aiohttp.ClientError as e:
        await processing.delete()
        logger.error(f"Backend connection error: {e}")
        await message.answer(
            "❌ Server bilan aloqa yo'q. Keyinroq qaytadan urinib ko'ring.",
            reply_markup=remove_keyboard()
        )
    except (ValueError, KeyError) as e:
        await processing.delete()
        logger.error(f"Response parse error: {e}")
        await message.answer(
            "❌ Serverdan noto'g'ri javob keldi. Keyinroq urinib ko'ring.",
            reply_markup=remove_keyboard()
        )
    except Exception as e:
        try:
            await processing.delete()
        except Exception:
            pass
        logger.error(f"Unexpected error in handle_contact: {e}", exc_info=True)
        await message.answer(
            "❌ Kutilmagan xato yuz berdi. Iltimos, keyinroq qaytadan urinib ko'ring.",
            reply_markup=remove_keyboard()
        )


@router.message(F.text)
async def handle_text(message: Message):
    await message.answer(
        "❌ <b>«📱 Telefon raqamni yuborish»</b> tugmasini bosing!",
        parse_mode="HTML"
    )
