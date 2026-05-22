"""
Custom exceptions
"""


class AuthError(Exception):
    """Base auth exception"""
    def __init__(self, message: str, code: str = "AUTH_ERROR"):
        self.message = message
        self.code = code
        super().__init__(self.message)


class TokenExpiredError(AuthError):
    """Token muddati tugagan"""
    def __init__(self):
        super().__init__(
            "Token muddati tugagan. Iltimos, qaytadan urinib ko'ring.",
            "TOKEN_EXPIRED"
        )


class TokenNotFoundError(AuthError):
    """Token topilmadi"""
    def __init__(self):
        super().__init__(
            "Token topilmadi. Iltimos, qaytadan urinib ko'ring.",
            "TOKEN_NOT_FOUND"
        )


class TokenAlreadyUsedError(AuthError):
    """Token allaqachon ishlatilgan"""
    def __init__(self):
        super().__init__(
            "Token allaqachon ishlatilgan.",
            "TOKEN_ALREADY_USED"
        )


class InvalidTokenError(AuthError):
    """Token noto'g'ri"""
    def __init__(self):
        super().__init__(
            "Token noto'g'ri. Iltimos, qaytadan urinib ko'ring.",
            "INVALID_TOKEN"
        )


class UserNotFoundError(AuthError):
    """User topilmadi"""
    def __init__(self):
        super().__init__(
            "Foydalanuvchi topilmadi.",
            "USER_NOT_FOUND"
        )