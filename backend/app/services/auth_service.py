"""
Auth business logic
"""
import json
import random
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.models.user import User
from app.core.redis import get_redis
from app.core.security import create_temp_token, create_access_token, decode_access_token
from app.core.exceptions import (
    TokenNotFoundError, TokenAlreadyUsedError,
    InvalidTokenError, UserNotFoundError
)
from app.config import settings
from app.schemas.auth import (
    TokenInitRequest, TokenInitResponse,
    PhoneVerifyRequest, PhoneVerifyResponse,
    PhoneLoginRequest, PhoneLoginResponse,
    VerifyCodeRequest, VerifyCodeResponse,
    ProfileSetupRequest
)


class AuthService:

    @staticmethod
    async def init_telegram_auth(request: TokenInitRequest) -> TokenInitResponse:
        """1. Flutter → temp token yaratish"""
        redis = await get_redis()
        token = create_temp_token()

        token_data = {
            "device_id": request.device_id,
            "created_at": datetime.utcnow().isoformat(),
            "used": False
        }
        await redis.setex(
            f"temp_token:{token}",
            settings.TEMP_TOKEN_EXPIRE_SECONDS,
            json.dumps(token_data)
        )

        bot_link = f"https://t.me/{settings.TELEGRAM_BOT_USERNAME}?start={token}"
        return TokenInitResponse(
            token=token,
            bot_link=bot_link,
            expires_in=settings.TEMP_TOKEN_EXPIRE_SECONDS
        )

    @staticmethod
    async def verify_phone(
        request: PhoneVerifyRequest,
        db: AsyncSession
    ) -> PhoneVerifyResponse:
        """2. Bot → telefon tekshirish va user yaratish"""
        redis = await get_redis()

        token_key = f"temp_token:{request.token}"
        token_data_str = await redis.get(token_key)
        if not token_data_str:
            raise TokenNotFoundError()

        token_data = json.loads(token_data_str)
        if token_data.get("used"):
            raise TokenAlreadyUsedError()

        # User topish yoki yaratish
        stmt = select(User).where(User.telegram_id == request.telegram_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            user = User(
                telegram_id=request.telegram_id,
                phone=request.phone,
                first_name=request.first_name,
                last_name=request.last_name,
                username=request.username,
                is_verified=True
            )
            db.add(user)
        else:
            user.phone = request.phone
            if request.first_name:
                user.first_name = request.first_name
            if request.last_name:
                user.last_name = request.last_name
            if request.username:
                user.username = request.username
            user.is_verified = True

        await db.commit()
        await db.refresh(user)

        # Token ishlatilgan deb belgilash
        token_data["used"] = True
        await redis.setex(token_key, 60, json.dumps(token_data))

        # JWT token
        access_token = create_access_token(
            data={"sub": str(user.telegram_id), "user_id": user.id}
        )

        # Deep link (yukgo:// scheme — AndroidManifest bilan mos)
        deep_link = f"yukgo://auth?token={access_token}"

        return PhoneVerifyResponse(
            success=True,
            auth_token=access_token,
            deep_link=deep_link,
            user_id=user.id,
            is_profile_complete=user.is_profile_complete or False
        )

    @staticmethod
    async def setup_profile(
        request: ProfileSetupRequest,
        user: User,
        db: AsyncSession
    ) -> User:
        """3. Profil to'ldirish"""
        user.role = request.role
        if request.first_name:
            user.first_name = request.first_name
        if request.last_name:
            user.last_name = request.last_name
        if request.phone:
            user.phone = request.phone
        if request.from_city:
            user.from_city = request.from_city
        if request.to_routes is not None:
            user.to_routes = json.dumps(request.to_routes)
        if request.truck_type:
            user.truck_type = request.truck_type
        if request.capacity:
            user.capacity = request.capacity
        if request.cargo_type:
            user.cargo_type = request.cargo_type

        user.is_profile_complete = True
        await db.commit()
        await db.refresh(user)
        return user

    @staticmethod
    async def phone_login(request: PhoneLoginRequest, db: AsyncSession) -> PhoneLoginResponse:
        """Bot → telefon oldi, user yarat, 6 xonali kod ber"""
        redis = await get_redis()

        stmt = select(User).where(User.telegram_id == request.telegram_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            user = User(
                telegram_id=request.telegram_id,
                phone=request.phone,
                first_name=request.first_name,
                last_name=request.last_name,
                username=request.username,
                is_verified=True
            )
            db.add(user)
        else:
            user.phone = request.phone
            if request.first_name:
                user.first_name = request.first_name
            if request.last_name:
                user.last_name = request.last_name
            if request.username:
                user.username = request.username
            user.is_verified = True

        await db.commit()
        await db.refresh(user)

        access_token = create_access_token(
            data={"sub": str(user.telegram_id), "user_id": user.id}
        )

        code = str(random.randint(100000, 999999))
        await redis.setex(f"otp:{code}", 300, access_token)

        return PhoneLoginResponse(code=code)

    @staticmethod
    async def verify_code(code: str) -> VerifyCodeResponse:
        """Flutter → kodni tekshir, JWT ber"""
        redis = await get_redis()
        token = await redis.get(f"otp:{code}")
        if not token:
            raise TokenNotFoundError()
        await redis.delete(f"otp:{code}")
        return VerifyCodeResponse(success=True, auth_token=token, is_profile_complete=False)

    @staticmethod
    async def get_current_user(token: str, db: AsyncSession) -> User:
        """Token orqali user olish"""
        payload = decode_access_token(token)

        user_id = payload.get("user_id")
        if not user_id:
            raise InvalidTokenError()

        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise UserNotFoundError()
        return user
