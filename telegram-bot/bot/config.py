"""
Bot sozlamalari
"""
from pydantic_settings import BaseSettings
from functools import lru_cache
import os


class BotSettings(BaseSettings):
    BOT_TOKEN: str
    BOT_USERNAME: str = "Logistics_login_bot"
    BACKEND_URL: str = "http://localhost:8000"
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> BotSettings:
    return BotSettings()


settings = get_settings()
