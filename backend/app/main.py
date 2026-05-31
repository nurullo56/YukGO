"""
FastAPI asosiy app
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from contextlib import asynccontextmanager
import os
from app.config import settings
from app.core.redis import close_redis
from app.api.v1.endpoints import auth, orders, chat, admin


@asynccontextmanager
async def lifespan(app: FastAPI):
    """App startup/shutdown"""
    from app.db.base import Base
    from app.db.session import engine
    import app.db.models  # noqa: barcha modellarni ro'yxatdan o'tkazish
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("Starting up...")
    yield
    print("Shutting down...")
    await close_redis()


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS — DEBUG=True da ochiq, production'da faqat ALLOWED_ORIGINS
_origins = (
    ["*"] if settings.DEBUG
    else [o.strip() for o in settings.ALLOWED_ORIGINS.split(",") if o.strip()]
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

# Routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(orders.router, prefix="/api/v1")
app.include_router(chat.router, prefix="/api/v1")
app.include_router(admin.router, prefix="/api/v1")


@app.get("/admin", include_in_schema=False)
async def admin_panel():
    path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "admin", "index.html")
    return FileResponse(path)


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