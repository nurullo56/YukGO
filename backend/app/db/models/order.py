"""
Order (Yuk buyurtmasi) modeli
"""
from sqlalchemy import Column, BigInteger, Integer, String, Boolean, DateTime, Text, Numeric, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base import Base


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)

    # Yukchi (buyurtmachi)
    yukchi_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)

    # Furachi (haydovchi) — qabul qilgandan keyin to'ldiriladi
    furachi_id = Column(BigInteger, ForeignKey("users.id"), nullable=True, index=True)

    # Yuk ma'lumotlari
    cargo_type = Column(String(100), nullable=False)
    from_city = Column(String(100), nullable=False)
    to_city = Column(String(100), nullable=False)
    weight_kg = Column(String(50), nullable=True)
    price = Column(String(50), nullable=True)
    description = Column(Text, nullable=True)

    # Holat: pending | accepted | in_transit | delivered | cancelled
    status = Column(String(30), default="pending", index=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relations
    yukchi = relationship("User", foreign_keys=[yukchi_id])
    furachi = relationship("User", foreign_keys=[furachi_id])

    def __repr__(self):
        return f"<Order {self.id} {self.from_city}→{self.to_city} [{self.status}]>"
