"""
Bot uchun klaviaturalar (Reply va Inline)
"""
from aiogram.types import (
    ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove,
    InlineKeyboardMarkup, InlineKeyboardButton
)
from aiogram.utils.keyboard import ReplyKeyboardBuilder, InlineKeyboardBuilder

# Tugma matnlari
SEND_PHONE_TEXT = "📱 Telefon raqamni yuborish"
BACK_TO_APP_TEXT = "📱 Ilovaga qaytish"

def get_phone_keyboard() -> ReplyKeyboardMarkup:
    builder = ReplyKeyboardBuilder()
    builder.add(KeyboardButton(
        text=SEND_PHONE_TEXT,
        request_contact=True
    ))
    return builder.as_markup(resize_keyboard=True, one_time_keyboard=True)


def get_back_to_app_keyboard(deep_link: str) -> InlineKeyboardMarkup:
    builder = InlineKeyboardBuilder()
    builder.add(InlineKeyboardButton(
        text=BACK_TO_APP_TEXT,
        url=deep_link
    ))
    return builder.as_markup()


def remove_keyboard() -> ReplyKeyboardRemove:
    return ReplyKeyboardRemove()