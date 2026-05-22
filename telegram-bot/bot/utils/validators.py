"""
Validatorlar
"""
import re


def is_valid_phone(phone: str) -> bool:
    """
    Telefon raqam formatini tekshirish
    """
    # Uzbekiston: +998 XX XXX XX XX
    pattern = r'^\+998\d{9}$'
    return bool(re.match(pattern, phone))


def normalize_phone(phone: str) -> str:
    """
    Telefon raqamni normallash
    """
    # Barcha bo'sh joylarni olib tashlash
    phone = phone.replace(" ", "").replace("-", "")
    
    # Agar + bo'lmasa qo'shish
    if not phone.startswith("+"):
        if phone.startswith("998"):
            phone = "+" + phone
        else:
            phone = "+998" + phone
    
    return phone