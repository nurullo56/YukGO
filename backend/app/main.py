"""
FastAPI asosiy app
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import settings
from app.core.redis import close_redis
from app.api.v1.endpoints import auth, orders, chat


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

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Production'da o'zgartiring!
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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