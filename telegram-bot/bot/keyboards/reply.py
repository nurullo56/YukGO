"""
Reply klaviaturalar
"""
from aiogram.types import (
    ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove,
    InlineKeyboardMarkup, InlineKeyboardButton
)
from aiogram.utils.keyboard import ReplyKeyboardBuilder, InlineKeyboardBuilder


def get_phone_keyboard() -> ReplyKeyboardMarkup:
    builder = ReplyKeyboardBuilder()
    builder.add(KeyboardButton(
        text="📱 Telefon raqamni yuborish",
        request_contact=True
    ))
    return builder.as_markup(resize_keyboard=True, one_time_keyboard=True)


def get_back_to_app_keyboard(deep_link: str) -> InlineKeyboardMarkup:
    builder = InlineKeyboardBuilder()
    builder.add(InlineKeyboardButton(
        text="📱 Ilovaga qaytish",
        url=deep_link
    ))
    return builder.as_markup()


def remove_keyboard() -> ReplyKeyboardRemove:
    return ReplyKeyboardRemove()