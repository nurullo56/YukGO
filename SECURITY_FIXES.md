# 🔐 YukGo Security Audit — Tuzatishlar Qo'llanmasi

**Audit Sanasi:** 2026-05-25  
**Auditor:** Claude Mythos Perspective  
**Loyiha:** YukGo Flutter + FastAPI Backend  
**Umumiy Xavf Darajasi:** 🔴 **CRITICAL** (4 Critical, 4 High issues)

---

## 📊 XULOSA

**Topilgan Muammolar: 10**
- 🔴 Critical: 4
- ⚠️ High: 4
- 🟡 Medium: 2

**Hozirgi Xavfsizlik Balli: 4/10**  
**Maqsad: 9/10** (Production-ready)

---

## 🚨 TEZKOR HARAKAT TALAB QILINADI (1 soat ichida)

### ❗ CRITICAL #1: Telegram Bot Token Exposed

**Muammo:**  
`.env` faylida bot token ochiq yotibdi va ZIP faylga tushgan.

```
TELEGRAM_BOT_TOKEN=8772815197:AAFiR1U5mrLLtk9PGEw9BRgrv-FzGz59QZE
```

**DARHOL BAJARING:**

1. **@BotFather'ga kiring va tokenni revoke qiling:**
```
/mybots
→ Logistics_login_bot ni tanla
→ API Token
→ Revoke current token
→ Yangi token oling
```

2. **Yangi tokenni `.env` ga qo'ying:**
```bash
# .env
TELEGRAM_BOT_TOKEN=YANGI_TOKEN_BU_YERDA
```

3. **Eski tokenni hech qayerda qoldirmang!**

---

### ❗ CRITICAL #2: Weak SECRET_KEY

**Muammo:**  
`backend/app/config.py` da default SECRET_KEY juda zaif.

**Hozirgi kod:**
```python
SECRET_KEY: str = "your-secret-key-change-in-production"
```

**TUZATISH:**

1. **Kuchli SECRET_KEY generate qiling:**
```bash
python -c "import secrets; print(secrets.token_urlsafe(64))"
```

Natija (masalan):
```
xK9mPq2vN8wR5tY7uZ3aB6cD1eF4gH0iJ2kL5mN8oP1qR4sT7uV0wX3yZ6aB9cD2eF5g
```

2. **`config.py` ni yangilang:**
```python
# backend/app/config.py
from pydantic_settings import BaseSettings
from pydantic import validator

class Settings(BaseSettings):
    APP_NAME: str = "Logistic Auth API"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    DATABASE_URL: str
    REDIS_URL: str
    
    # Security - NO DEFAULT!
    SECRET_KEY: str  # .env'dan majburiy
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7
    
    TELEGRAM_BOT_TOKEN: str
    TELEGRAM_BOT_USERNAME: str
    TEMP_TOKEN_EXPIRE_SECONDS: int = 300
    
    # Production settings
    ALLOWED_ORIGINS: str = "*"  # CSV format: "https://yukgo.uz,https://app.yukgo.uz"
    
    @validator('SECRET_KEY')
    def validate_secret_key(cls, v):
        if len(v) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters!")
        if v in ["your-secret-key-change-in-production", "change-this"]:
            raise ValueError("SECRET_KEY cannot be a default value!")
        return v
    
    class Config:
        env_file = (".env.local", ".env")
        case_sensitive = True
```

3. **`.env` ni yangilang:**
```bash
# Security
SECRET_KEY=xK9mPq2vN8wR5tY7uZ3aB6cD1eF4gH0iJ2kL5mN8oP1qR4sT7uV0wX3yZ6aB9cD2eF5g
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# Production CORS
ALLOWED_ORIGINS=https://yukgo.uz,https://app.yukgo.uz
```

---

### ❗ CRITICAL #3: CORS Wildcard

**Muammo:**  
`backend/app/main.py` da CORS har qanday domenga ochiq.

**Hozirgi kod:**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # XAVFLI!
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**TUZATISH:**

```python
# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import settings
from app.core.redis import close_redis
from app.api.v1.endpoints import auth, orders, chat


@asynccontextmanager
async def lifespan(app: FastAPI):
    from app.db.base import Base
    from app.db.session import engine
    import app.db.models
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("✅ Starting up...")
    yield
    print("🛑 Shutting down...")
    await close_redis()


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS - Production safe
allowed_origins = (
    ["*"] if settings.DEBUG 
    else [origin.strip() for origin in settings.ALLOWED_ORIGINS.split(",")]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

# Routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(orders.router, prefix="/api/v1")
app.include_router(chat.router, prefix="/api/v1")


@app.get("/")
async def root():
    return {
        "app": settings.APP_NAME,
        "version": settings.VERSION,
        "status": "running"
    }


@app.get("/health")
async def health():
    return {"status": "ok"}
```

---

### ❗ CRITICAL #4: .env File Exposure

**Muammo:**  
`.env` fayli ZIP'ga tushgan va secrets expose bo'lgan.

**TUZATISH:**

1. **`.env` ni Git'dan olib tashlang (agar commit qilgan bo'lsangiz):**
```bash
# Agar .env commit qilingan bo'lsa
git rm --cached .env
git rm --cached backend/.env
git commit -m "Remove .env from git"

# Git history'dan butunlay o'chirish (XAVFLI - team bilan kelishing!)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env backend/.env" \
  --prune-empty --tag-name-filter cat -- --all
```

2. **`.env.example` yarating:**
```bash
# .env.example
# App
DEBUG=False

# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/dbname
REDIS_URL=redis://localhost:6379/0

# Security (Generate with: python -c "import secrets; print(secrets.token_urlsafe(64))")
SECRET_KEY=YOUR_SECRET_KEY_HERE
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# Telegram
TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN_HERE
TELEGRAM_BOT_USERNAME=your_bot_username

# CORS
ALLOWED_ORIGINS=https://yukgo.uz,https://app.yukgo.uz

# Temp Token
TEMP_TOKEN_EXPIRE_SECONDS=300
```

3. **`.gitignore` ni tekshiring:**
```bash
# Secrets & Environment (allaqachon bor)
.env
.env.local
.env.production
**/.env
**/.env.local
!**/.env.example

# SQLite databases
*.db
*.sqlite
*.sqlite3

# Firebase
**/firebase-service-account.json
```

4. **Keyinchalik ZIP yaratishda exclude qiling:**
```bash
# To'g'ri ZIP yaratish
zip -r yukgo_source.zip . \
  -x "*.env*" \
  -x "*.db" \
  -x "*.sqlite*" \
  -x "*firebase-service-account.json" \
  -x "*/__pycache__/*" \
  -x "*/build/*" \
  -x "*/.dart_tool/*" \
  -x "*.apk" \
  -x "*.aab"
```

---

## ⚠️ HIGH PRIORITY FIXES (3 soat ichida)

### ⚠️ HIGH #1: OTP Brute-Force Vulnerability

**Muammo:**  
6 xonali OTP kod, rate limiting yo'q → 1,000,000 ta variant, brute-force mumkin.

**Hozirgi kod:**
```python
# backend/app/services/auth_service.py:183-186
code = str(random.randint(100000, 999999))
await redis.setex(f"otp:{code}", 300, access_token)
```

**TUZATISH:**

1. **`slowapi` ni o'rnating:**
```bash
cd backend
pip install slowapi
pip freeze > requirements.txt
```

2. **Rate limiter qo'shing:**
```python
# backend/app/main.py
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

# ... (lifespan va app definition)

# Rate limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
```

3. **Auth endpoint'larda limit qo'llang:**
```python
# backend/app/api/v1/endpoints/auth.py
from slowapi import Limiter
from slowapi.util import get_remote_address
from fastapi import Request

limiter = Limiter(key_func=get_remote_address)

# ... (router definition)

@router.post("/phone-login", response_model=PhoneLoginResponse)
@limiter.limit("3/minute")  # Max 3 OTP per minute per IP
async def phone_login(
    request: Request,  # slowapi uchun kerak
    body: PhoneLoginRequest,
    db: AsyncSession = Depends(get_db)
):
    """Bot → telefon oldi, user yarat, 6 xonali kod ber"""
    try:
        return await AuthService.phone_login(body, db)
    except Exception as e:
        logger.error(f"Phone login error: {e}")
        raise HTTPException(status_code=500, detail="Server xatosi")


@router.post("/verify-code", response_model=VerifyCodeResponse)
@limiter.limit("5/minute")  # Max 5 attempts per minute
async def verify_code(
    request: Request,
    body: VerifyCodeRequest,
    db: AsyncSession = Depends(get_db)
):
    """Flutter → kodni tekshir, JWT ber"""
    try:
        return await AuthService.verify_code(body.code, db, request.client.host)
    except AuthError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": e.code, "message": e.message}
        )
    except Exception as e:
        logger.error(f"Verify code error: {e}")
        raise HTTPException(status_code=500, detail="Server xatosi")
```

4. **Service layer'da attempt tracking:**
```python
# backend/app/services/auth_service.py
@staticmethod
async def verify_code(code: str, db: AsyncSession, client_ip: str) -> VerifyCodeResponse:
    """Flutter → kodni tekshir, JWT ber"""
    redis = await get_redis()
    
    # Attempt tracking
    attempts_key = f"otp_attempts:{client_ip}"
    attempts = await redis.get(attempts_key)
    
    if attempts and int(attempts) > 10:
        raise AuthError("TOO_MANY_ATTEMPTS", "Juda ko'p urinish. 5 minut kuting.")
    
    # Check OTP
    token = await redis.get(f"otp:{code}")
    if not token:
        # Increment attempts
        await redis.incr(attempts_key)
        await redis.expire(attempts_key, 300)  # 5 minutes
        raise TokenNotFoundError()
    
    # Success - clear attempts
    await redis.delete(f"otp:{code}")
    await redis.delete(attempts_key)
    
    # ... (rest of the code)
```

---

### ⚠️ HIGH #2: FakeRedis — Global State

**Muammo:**  
Production'da `FakeRedis` ishlatilsa — multi-worker environment'da race condition va state loss.

**TUZATISH:**

1. **Real Redis'ga o'tish (Production):**
```bash
# Docker Compose'da Redis qo'shing
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

2. **Redis client yangilash:**
```python
# backend/app/core/redis.py
import os
from typing import Optional
from redis.asyncio import Redis, ConnectionPool

_redis_pool: Optional[ConnectionPool] = None
_redis_client: Optional[Redis] = None


async def get_redis() -> Redis:
    """
    Redis connection pool bilan singleton pattern.
    Production: real Redis
    Development: FakeRedis fallback
    """
    global _redis_pool, _redis_client
    
    from app.config import settings
    
    # Production - real Redis
    if not settings.DEBUG or "redis://" in settings.REDIS_URL:
        if _redis_pool is None:
            _redis_pool = ConnectionPool.from_url(
                settings.REDIS_URL,
                decode_responses=True,
                max_connections=10
            )
            _redis_client = Redis(connection_pool=_redis_pool)
        return _redis_client
    
    # Development - FakeRedis fallback
    else:
        from app.core.fake_redis import FakeRedis
        if _redis_client is None:
            _redis_client = FakeRedis()
        return _redis_client


async def close_redis():
    """Cleanup on shutdown"""
    global _redis_pool, _redis_client
    if _redis_client:
        await _redis_client.aclose()
        _redis_client = None
    if _redis_pool:
        await _redis_pool.disconnect()
        _redis_pool = None
```

3. **FakeRedis'ni alohida faylga ko'chiring:**
```python
# backend/app/core/fake_redis.py
"""
Development-only in-memory Redis replacement.
DO NOT USE IN PRODUCTION!
"""
import time
from typing import Optional

_store: dict = {}
_expiry: dict = {}


class FakeRedis:
    """In-memory Redis mock for development"""
    
    async def setex(self, key: str, ttl: int, value: str):
        _store[key] = value
        _expiry[key] = time.time() + ttl
    
    async def get(self, key: str) -> Optional[str]:
        if key not in _store:
            return None
        if time.time() > _expiry.get(key, float('inf')):
            del _store[key]
            del _expiry[key]
            return None
        return _store[key]
    
    async def delete(self, key: str):
        _store.pop(key, None)
        _expiry.pop(key, None)
    
    async def incr(self, key: str) -> int:
        current = _store.get(key, "0")
        new_val = int(current) + 1
        _store[key] = str(new_val)
        return new_val
    
    async def expire(self, key: str, ttl: int):
        if key in _store:
            _expiry[key] = time.time() + ttl
    
    async def aclose(self):
        pass
```

4. **`requirements.txt` update:**
```bash
# backend/requirements.txt
redis==5.0.1
# aioredis==2.0.1  # DEPRECATED - o'chirildi
```

---

### ⚠️ HIGH #3: WebSocket Token in Query String

**Muammo:**  
WebSocket token query parameter'da → logs'ga tushadi.

**Hozirgi kod:**
```python
@router.websocket("/ws/{room_id}")
async def chat_ws(room_id: str, websocket: WebSocket, token: str = Query(...)):
```

**TUZATISH:**

**Backend:**
```python
# backend/app/api/v1/endpoints/chat.py
@router.websocket("/ws/{room_id}")
async def chat_ws(room_id: str, websocket: WebSocket):
    """
    WebSocket chat endpoint.
    Token should be sent via Sec-WebSocket-Protocol header.
    """
    # Extract token from subprotocol header
    protocols = websocket.headers.get("sec-websocket-protocol", "")
    token = None
    
    if protocols:
        # Format: "token, other-protocol"
        parts = [p.strip() for p in protocols.split(",")]
        token = parts[0] if parts else None
    
    if not token:
        await websocket.close(code=4001, reason="Missing authentication token")
        return
    
    # Authenticate
    async with async_session_maker() as db:
        try:
            user: User = await AuthService.get_current_user(token, db)
        except AuthError:
            await websocket.close(code=4001, reason="Invalid token")
            return
    
    # ... (rest of WebSocket logic)
```

**Flutter Client:**
```dart
// lib/core/services/chat_service.dart
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  WebSocketChannel connectToRoom(String roomId, String authToken) {
    final uri = Uri.parse('wss://api.yukgo.uz/api/v1/chat/ws/$roomId');
    
    // Token in Sec-WebSocket-Protocol header
    return WebSocketChannel.connect(
      uri,
      protocols: [authToken],  // ✅ Secure way
    );
  }
}
```

---

### ⚠️ HIGH #4: Telegram Bot Handler Incomplete

**Muammo:**  
Contact handler backend'ga telefon yubormaяpti.

**Hozirgi kod:**
```python
@router.message(F.contact)
async def handle_contact(message: types.Message):
    # Bu yerda message.contact.phone_number orqali raqamni olishingiz mumkin
    # NO BACKEND CALL!
```

**TUZATISH:**

```python
# telegram-bot/bot/handlers/auth.py
from aiogram import Router, types, F
from aiogram.filters import CommandStart, Command
from aiogram.fsm.context import FSMContext
from bot.keyboards.reply import get_phone_keyboard, get_back_to_app_keyboard, remove_keyboard
from bot.services.api_client import api_client
from bot.states import AuthStates
import logging

logger = logging.getLogger(__name__)
router = Router()


@router.message(CommandStart())
async def cmd_start(message: types.Message, state: FSMContext):
    """
    /start [token] - Auth flow boshlash
    """
    # Extract token from deep link
    args = message.text.split()
    token = args[1] if len(args) > 1 else None
    
    if not token:
        await message.answer(
            "❌ Noto'g'ri link. Iltimos, ilovadan qayta urinib ko'ring."
        )
        return
    
    # Save token to FSM state
    await state.update_data(auth_token=token)
    await state.set_state(AuthStates.waiting_contact)
    
    await message.answer(
        "👋 Xush kelibsiz!\n\n"
        "Botdan foydalanish uchun telefon raqamingizni yuboring.",
        reply_markup=get_phone_keyboard()
    )


@router.message(AuthStates.waiting_contact, F.contact)
async def handle_contact(message: types.Message, state: FSMContext):
    """
    Contact qabul qilish va backend'ga yuborish
    """
    phone = message.contact.phone_number
    telegram_id = message.from_user.id
    
    # Get saved token from state
    data = await state.get_data()
    token = data.get("auth_token")
    
    if not token:
        await message.answer(
            "❌ Sessiya muddati tugagan. Iltimos, ilovadan qayta boshlang.",
            reply_markup=remove_keyboard()
        )
        await state.clear()
        return
    
    # Show loading
    status_msg = await message.answer(
        "⏳ Tekshirilmoqda...",
        reply_markup=remove_keyboard()
    )
    
    try:
        # Call backend API
        result = await api_client.verify_phone(
            token=token,
            telegram_id=telegram_id,
            phone=phone,
            first_name=message.from_user.first_name,
            last_name=message.from_user.last_name,
            username=message.from_user.username
        )
        
        if result and result.get("success"):
            deep_link = result.get("deep_link", "yukgo://")
            
            await status_msg.edit_text(
                "✅ Telefon raqamingiz muvaffaqiyatli tasdiqlandi!\n\n"
                "Ilovaga qaytish uchun quyidagi tugmani bosing:"
            )
            
            await message.answer(
                "👇 Ilovaga qaytish:",
                reply_markup=get_back_to_app_keyboard(deep_link)
            )
            
            logger.info(f"✅ User {telegram_id} verified successfully")
        else:
            await status_msg.edit_text(
                "❌ Xatolik yuz berdi. Iltimos, ilovadan qayta urinib ko'ring."
            )
            logger.error(f"❌ Backend returned error for user {telegram_id}")
    
    except Exception as e:
        await status_msg.edit_text(
            "❌ Serverda muammo. Iltimos, keyinroq qayta urinib ko'ring."
        )
        logger.error(f"❌ Error handling contact for {telegram_id}: {e}")
    
    finally:
        await state.clear()


@router.message(F.contact)
async def handle_contact_without_state(message: types.Message):
    """
    Agar state bo'lmasa (token yo'q)
    """
    await message.answer(
        "❌ Iltimos, ilovadan /start linkni bosing.",
        reply_markup=remove_keyboard()
    )
```

```python
# telegram-bot/bot/states.py
from aiogram.fsm.state import State, StatesGroup

class AuthStates(StatesGroup):
    waiting_contact = State()
```

---

## 🟡 MEDIUM PRIORITY FIXES (1 kun ichida)

### 🟡 MEDIUM #1: Order Accept Race Condition

**Muammo:**  
Ikki driver bir vaqtda bitta orderni accept qilishi mumkin.

**TUZATISH:**

```python
# backend/app/api/v1/endpoints/orders.py
from sqlalchemy import update

@router.patch("/{order_id}/accept", response_model=OrderResponse)
async def accept_order(
    order_id: int,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Furachi — buyurtmani qabul qilish (atomic update bilan race condition'dan himoya)
    """
    user = await get_user(authorization, db)
    if user.role != "furachi":
        raise HTTPException(status_code=403, detail="Faqat furachilар qabul qiladi")
    
    # Atomic UPDATE WHERE condition
    stmt = (
        update(Order)
        .where(
            Order.id == order_id,
            Order.status == "pending",
            Order.furachi_id == None  # Hali hech kim accept qilmagan
        )
        .values(furachi_id=user.id, status="accepted")
        .execution_options(synchronize_session=False)
    )
    
    result = await db.execute(stmt)
    await db.commit()
    
    # Check if update succeeded
    if result.rowcount == 0:
        # Order allaqachon accept qilingan yoki topilmagan
        check_stmt = select(Order).where(Order.id == order_id)
        check_result = await db.execute(check_stmt)
        existing_order = check_result.scalar_one_or_none()
        
        if not existing_order:
            raise HTTPException(status_code=404, detail="Buyurtma topilmadi")
        else:
            raise HTTPException(
                status_code=409,
                detail="Buyurtma allaqachon boshqa haydovchi tomonidan qabul qilingan"
            )
    
    # Fetch updated order with relations
    stmt2 = (
        select(Order)
        .options(selectinload(Order.yukchi), selectinload(Order.furachi))
        .where(Order.id == order_id)
    )
    result2 = await db.execute(stmt2)
    order = result2.scalar_one()
    
    logger.info(f"✅ Order {order_id} accepted by furachi {user.id}")
    return order
```

---

### 🟡 MEDIUM #2: Order Input Validation

**Muammo:**  
Order create'da input validation zaif.

**TUZATISH:**

```python
# backend/app/schemas/auth.py (yoki yangi schemas/orders.py yarating)
from pydantic import BaseModel, Field, validator
from typing import Optional

class OrderCreateRequest(BaseModel):
    cargo_type: str = Field(..., min_length=1, max_length=100)
    from_city: str = Field(..., min_length=1, max_length=100)
    to_city: str = Field(..., min_length=1, max_length=100)
    weight_kg: str = Field(..., pattern=r'^\d+(\.\d{1,2})?$')  # "100" or "100.5"
    price: str = Field(..., pattern=r'^\d+(\.\d{1,2})?$')
    description: Optional[str] = Field(None, max_length=1000)
    
    @validator('to_city')
    def validate_different_cities(cls, v, values):
        if v == values.get('from_city'):
            raise ValueError("Boshlanish va tugash shaharlari bir xil bo'lmasligi kerak")
        return v
    
    @validator('weight_kg', 'price')
    def validate_positive(cls, v, field):
        try:
            num = float(v)
            if num <= 0:
                raise ValueError(f"{field.name} musbat bo'lishi kerak")
        except ValueError:
            raise ValueError(f"{field.name} noto'g'ri format")
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "cargo_type": "Meva-sabzavot",
                "from_city": "Toshkent",
                "to_city": "Samarqand",
                "weight_kg": "500",
                "price": "150000",
                "description": "Tezkor yetkazish talab qilinadi"
            }
        }


class OrderStatusUpdate(BaseModel):
    status: str = Field(..., pattern=r'^(pending|accepted|in_transit|delivered|cancelled)$')
    
    @validator('status')
    def validate_status(cls, v):
        allowed = ["pending", "accepted", "in_transit", "delivered", "cancelled"]
        if v not in allowed:
            raise ValueError(f"Status faqat {allowed} dan biri bo'lishi kerak")
        return v
```

---

## 📋 PRODUCTION DEPLOYMENT CHECKLIST

### 1. Environment Variables

```bash
# .env (Production)
DEBUG=False

# Database
DATABASE_URL=postgresql+asyncpg://yukgo_user:STRONG_PASSWORD@db:5432/yukgo_db

# Redis
REDIS_URL=redis://redis:6379/0

# Security
SECRET_KEY=<64_char_random_generated_key>
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# Telegram
TELEGRAM_BOT_TOKEN=<new_token_from_botfather>
TELEGRAM_BOT_USERNAME=Logistics_login_bot

# CORS
ALLOWED_ORIGINS=https://yukgo.uz,https://app.yukgo.uz

# Temp Token
TEMP_TOKEN_EXPIRE_SECONDS=300
```

### 2. Dependencies Update

```bash
# backend/requirements.txt
fastapi==0.115.0
alembic==1.13.1
uvicorn[standard]==0.30.0
sqlalchemy==2.0.35
asyncpg==0.29.0
redis==5.0.8
python-jose[cryptography]==3.3.0
pydantic==2.9.0
pydantic-settings==2.5.0
python-dotenv==1.0.1
aiohttp==3.10.0
httpx==0.27.0
slowapi==0.1.9  # NEW - rate limiting
firebase-admin==6.5.0
```

### 3. Docker Compose (Production)

```yaml
# docker-compose.yml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      - db
      - redis
    restart: unless-stopped
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

  telegram-bot:
    build: ./telegram-bot
    env_file:
      - .env
    depends_on:
      - backend
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### 4. Nginx Configuration

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=10r/m;

    server {
        listen 80;
        server_name api.yukgo.uz;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.yukgo.uz;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # API endpoints
        location /api/ {
            limit_req zone=api_limit burst=20 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Auth endpoints (stricter limit)
        location /api/v1/auth/ {
            limit_req zone=auth_limit burst=5 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # WebSocket
        location /api/v1/chat/ws/ {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

### 5. Deployment Script

```bash
#!/bin/bash
# deploy.sh

set -e

echo "🚀 Deploying YukGo Backend..."

# 1. Pull latest code
git pull origin main

# 2. Backup database
docker-compose exec db pg_dump -U yukgo_user yukgo_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 3. Stop services
docker-compose down

# 4. Rebuild
docker-compose build

# 5. Run migrations
docker-compose run --rm backend alembic upgrade head

# 6. Start services
docker-compose up -d

# 7. Health check
sleep 5
curl -f http://localhost:8000/health || exit 1

echo "✅ Deployment successful!"
```

---

## 🔍 MONITORING & LOGGING

### 1. Sentry Integration

```bash
pip install sentry-sdk[fastapi]
```

```python
# backend/app/main.py
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="https://your-sentry-dsn@sentry.io/project",
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,
    environment="production" if not settings.DEBUG else "development"
)
```

### 2. Structured Logging

```python
# backend/app/core/logging_config.py
import logging
import sys
from pythonjsonlogger import jsonlogger

def setup_logging():
    logHandler = logging.StreamHandler(sys.stdout)
    formatter = jsonlogger.JsonFormatter(
        '%(asctime)s %(name)s %(levelname)s %(message)s'
    )
    logHandler.setFormatter(formatter)
    
    root_logger = logging.getLogger()
    root_logger.addHandler(logHandler)
    root_logger.setLevel(logging.INFO)
```

---

## 📊 TESTING CHECKLIST

```bash
# 1. Security tests
pytest tests/security/test_auth.py
pytest tests/security/test_rate_limits.py

# 2. Load testing
locust -f tests/load/locustfile.py --host=https://api.yukgo.uz

# 3. SQL injection tests
sqlmap -u "https://api.yukgo.uz/api/v1/auth/verify" --data="..." --level=5

# 4. CORS testing
curl -H "Origin: https://evil.com" https://api.yukgo.uz/api/v1/auth/me

# 5. Rate limit testing
for i in {1..100}; do curl https://api.yukgo.uz/api/v1/auth/phone-login; done
```

---

## ✅ VERIFICATION STEPS

1. **Critical Issues:**
   - [ ] Bot token revoke qilindi va yangi token olingan
   - [ ] SECRET_KEY 32+ chars, unique generated
   - [ ] CORS faqat allowed domains
   - [ ] .env gitignore'da va Git history'dan o'chirilgan

2. **High Priority:**
   - [ ] Rate limiting (slowapi) o'rnatilgan va test qilingan
   - [ ] Real Redis production'da ishlamoqda
   - [ ] WebSocket token header'da (query string emas)
   - [ ] Telegram bot contact handler backend'ga call qilyapti

3. **Medium Priority:**
   - [ ] Order accept atomic update bilan
   - [ ] Pydantic validation barcha input'larda

4. **Production:**
   - [ ] Docker Compose ishlayapti
   - [ ] Nginx SSL bilan configured
   - [ ] Database backup script
   - [ ] Monitoring (Sentry) setup

---

## 🎯 FINAL SECURITY SCORE TARGET

**Hozirgi:** 4/10  
**Maqsad:** 9/10

**Qachon 9/10 bo'ladi:**
- ✅ Barcha Critical fixes applied
- ✅ Barcha High fixes applied
- ✅ Medium fixes applied
- ✅ Production deployment setup
- ✅ Monitoring active
- ✅ Regular security updates


**Oxirgi Yangilanish:** 2026-05-25  
**Keyingi Audit:** 2026-08-25 (3 oydan keyin)