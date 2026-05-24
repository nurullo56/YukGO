"""
User modeli
"""
from sqlalchemy import Column, BigInteger, Integer, String, Boolean, DateTime, Text
from sqlalchemy.sql import func
from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    telegram_id = Column(BigInteger, unique=True, nullable=False, index=True)
    phone = Column(String(20), unique=True, nullable=False, index=True)
    first_name = Column(String(255), nullable=True)
    last_name = Column(String(255), nullable=True)
    username = Column(String(255), nullable=True)

    # Rol: yukchi | furachi
    role = Column(String(20), nullable=True)
    is_profile_complete = Column(Boolean, default=False)

    # Furachi profili
    truck_type = Column(String(100), nullable=True)
    capacity = Column(String(50), nullable=True)

    # Umumiy profil
    from_city = Column(String(100), nullable=True)
    to_routes = Column(Text, nullable=True)   # JSON list: '["Samarqand","Buxoro"]'

    # Yukchi profili
    cargo_type = Column(String(100), nullable=True)

    fcm_token = Column(String(512), nullable=True)  # Push notification token

    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    def __repr__(self):
        return f"<User {self.telegram_id} - {self.phone} - {self.role}>"
