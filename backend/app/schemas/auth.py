"""
Pydantic schemas (Request/Response)
"""
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List


class TokenInitRequest(BaseModel):
    device_id: str = Field(..., min_length=1, max_length=255)


class TokenInitResponse(BaseModel):
    token: str
    bot_link: str
    expires_in: int


class PhoneVerifyRequest(BaseModel):
    token: str
    telegram_id: int
    phone: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    username: Optional[str] = None


class PhoneVerifyResponse(BaseModel):
    success: bool
    auth_token: str
    deep_link: str
    user_id: int
    is_profile_complete: bool = False


class PhoneLoginRequest(BaseModel):
    telegram_id: int
    phone: str
    first_name: Optional[str] = ""
    last_name: Optional[str] = ""
    username: Optional[str] = ""


class PhoneLoginResponse(BaseModel):
    code: str


class VerifyCodeRequest(BaseModel):
    code: str


class VerifyCodeResponse(BaseModel):
    success: bool
    auth_token: str
    is_profile_complete: bool = False


class ProfileSetupRequest(BaseModel):
    role: str = Field(..., pattern="^(yukchi|furachi)$")
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    # Furachi
    truck_type: Optional[str] = None
    capacity: Optional[str] = None
    # Umumiy
    from_city: Optional[str] = None
    to_routes: Optional[List[str]] = None
    # Yukchi
    cargo_type: Optional[str] = None


class UserResponse(BaseModel):
    id: int
    telegram_id: int
    phone: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    username: Optional[str] = None
    role: Optional[str] = None
    is_profile_complete: bool = False
    truck_type: Optional[str] = None
    capacity: Optional[str] = None
    from_city: Optional[str] = None
    cargo_type: Optional[str] = None
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ─── Orders ──────────────────────────────────────────────────────────────────

class OrderCreateRequest(BaseModel):
    cargo_type: str
    from_city: str
    to_city: str
    weight_kg: Optional[str] = None
    price: Optional[str] = None
    description: Optional[str] = None


class OrderResponse(BaseModel):
    id: int
    yukchi_id: int
    furachi_id: Optional[int] = None
    cargo_type: str
    from_city: str
    to_city: str
    weight_kg: Optional[str] = None
    price: Optional[str] = None
    description: Optional[str] = None
    status: str
    created_at: datetime
    yukchi: Optional[UserResponse] = None

    class Config:
        from_attributes = True


class OrderStatusUpdate(BaseModel):
    status: str = Field(..., pattern="^(accepted|in_transit|delivered|cancelled)$")
