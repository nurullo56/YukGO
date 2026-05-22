"""
Auth API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, Header, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.services.auth_service import AuthService
from app.core.exceptions import AuthError
from app.schemas.auth import (
    TokenInitRequest, TokenInitResponse,
    PhoneVerifyRequest, PhoneVerifyResponse,
    PhoneLoginRequest, PhoneLoginResponse,
    VerifyCodeRequest, VerifyCodeResponse,
    ProfileSetupRequest, UserResponse
)
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/init", response_model=TokenInitResponse)
async def init_auth(request: TokenInitRequest):
    """
    Flutter'dan: Telegram auth boshlash
    """
    try:
        return await AuthService.init_telegram_auth(request)
    except Exception as e:
        logger.error(f"Init auth error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Xatolik yuz berdi. Iltimos, qaytadan urinib ko'ring."
        )


@router.post("/verify", response_model=PhoneVerifyResponse)
async def verify_phone(
    request: PhoneVerifyRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Bot'dan: Telefon raqam tekshirish
    """
    try:
        return await AuthService.verify_phone(request, db)
    except AuthError as e:
        logger.warning(f"Auth error: {e.code} - {e.message}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": e.code, "message": e.message}
        )
    except Exception as e:
        logger.error(f"Verify phone error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Server xatosi. Iltimos, keyinroq qaytadan urinib ko'ring."
        )


@router.post("/phone-login", response_model=PhoneLoginResponse)
async def phone_login(
    request: PhoneLoginRequest,
    db: AsyncSession = Depends(get_db)
):
    """Bot'dan: Telefon oldi → 6 xonali kod ber"""
    try:
        return await AuthService.phone_login(request, db)
    except Exception as e:
        logger.error(f"Phone login error: {e}")
        raise HTTPException(status_code=500, detail="Server xatosi")


@router.post("/verify-code", response_model=VerifyCodeResponse)
async def verify_code(request: VerifyCodeRequest):
    """Flutter'dan: Kod → JWT token ber"""
    try:
        return await AuthService.verify_code(request.code)
    except AuthError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": e.code, "message": e.message}
        )
    except Exception as e:
        logger.error(f"Verify code error: {e}")
        raise HTTPException(status_code=500, detail="Server xatosi")


@router.get("/me", response_model=UserResponse)
async def get_me(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Flutter'dan: Hozirgi user ma'lumotlari
    Authorization: Bearer <token>
    """
    try:
        # Bearer token'ni ajratib olish
        if not authorization.startswith("Bearer "):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authorization header"
            )
        
        token = authorization[7:]  # "Bearer " ni olib tashlash
        user = await AuthService.get_current_user(token, db)
        return user
    except AuthError as e:
        logger.warning(f"Auth error: {e.code}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=e.message
        )
    except ValueError as e:
        logger.warning(f"Token validation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token noto'g'ri"
        )
    except Exception as e:
        logger.error(f"Get current user error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Server xatosi"
        )


@router.get("/drivers", response_model=list[UserResponse])
async def list_drivers(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Yukchi uchun: furachi ro'yxati"""
    from sqlalchemy import select as sa_select
    from app.db.models.user import User as UserModel
    try:
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid token")
        await AuthService.get_current_user(authorization[7:], db)
        stmt = sa_select(UserModel).where(UserModel.role == "furachi", UserModel.is_active == True)
        result = await db.execute(stmt)
        return result.scalars().all()
    except AuthError as e:
        raise HTTPException(status_code=401, detail=e.message)


@router.patch("/profile", response_model=UserResponse)
async def setup_profile(
    request: ProfileSetupRequest,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Profil to'ldirish (ro'yxatdan o'tgandan keyin)"""
    try:
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid token")
        token = authorization[7:]
        user = await AuthService.get_current_user(token, db)
        updated = await AuthService.setup_profile(request, user, db)
        return updated
    except AuthError as e:
        raise HTTPException(status_code=401, detail=e.message)
    except Exception as e:
        logger.error(f"Profile setup error: {e}")
        raise HTTPException(status_code=500, detail="Server xatosi")