"""
Barcha sozlamalar bir joyda
"""
from pydantic_settings import BaseSettings
from pydantic import field_validator
from functools import lru_cache

_WEAK_KEYS = {"your-secret-key-change-in-production", "change-this", "secret", ""}


class Settings(BaseSettings):
    # App
    APP_NAME: str = "Logistic Auth API"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://user:pass@localhost:5432/logistic"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 kun

    # CORS — production'da vergul bilan ajratilgan domenlar
    ALLOWED_ORIGINS: str = "*"

    # Admin panel
    ADMIN_SECRET: str = "yukgo@admin2024"

    # Telegram
    TELEGRAM_BOT_TOKEN: str = ""
    TELEGRAM_BOT_USERNAME: str = ""

    # Temp token settings
    TEMP_TOKEN_EXPIRE_SECONDS: int = 300  # 5 minut

    @field_validator("SECRET_KEY")
    @classmethod
    def validate_secret_key(cls, v: str) -> str:
        return v

    class Config:
        env_file = (".env.local", ".env")
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()