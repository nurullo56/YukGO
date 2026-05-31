from aiogram import Router, types, F
from aiogram.filters import CommandStart
from bot.keyboards.reply import get_phone_keyboard, get_back_to_app_keyboard, remove_keyboard

router = Router()

@router.message(CommandStart())
async def cmd_start(message: types.Message):
    """
    Foydalanuvchi /start yuborganda telefon raqamini so'rash klaviaturasini ko'rsatadi.
    """
    await message.answer(
        "Xush kelibsiz! Botdan to'liq foydalanish uchun telefon raqamingizni yuboring.",
        reply_markup=get_phone_keyboard()
    )

@router.message(F.contact)
async def handle_contact(message: types.Message):
    """
    Foydalanuvchi kontakt yuborganida ishlaydi. 
    Reply klaviaturani olib tashlaydi va inline tugmani ko'rsatadi.
    """
    # Bu yerda message.contact.phone_number orqali raqamni olishingiz mumkin
    
    await message.answer(
        "Raqamingiz muvaffaqiyatli qabul qilindi!",
        reply_markup=remove_keyboard()
    )

    # Deep link orqali ilovaga qaytish tugmasini ko'rsatamiz
    app_link = "https://t.me/your_bot_username/app_name"
    await message.answer(
        "Ilovaga qaytish uchun quyidagi tugmani bosing:",
        reply_markup=get_back_to_app_keyboard(app_link)
    )