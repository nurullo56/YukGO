"""Add profile fields and orders table

Revision ID: 002
Revises: 001
Create Date: 2026-05-21
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '002'
down_revision: Union[str, None] = '001'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Users jadvaliga yangi ustunlar
    op.add_column('users', sa.Column('role', sa.String(20), nullable=True))
    op.add_column('users', sa.Column('is_profile_complete', sa.Boolean(), nullable=True, server_default='false'))
    op.add_column('users', sa.Column('truck_type', sa.String(100), nullable=True))
    op.add_column('users', sa.Column('capacity', sa.String(50), nullable=True))
    op.add_column('users', sa.Column('from_city', sa.String(100), nullable=True))
    op.add_column('users', sa.Column('to_routes', sa.Text(), nullable=True))
    op.add_column('users', sa.Column('cargo_type', sa.String(100), nullable=True))

    # Orders jadvali
    op.create_table(
        'orders',
        sa.Column('id', sa.BigInteger(), nullable=False),
        sa.Column('yukchi_id', sa.BigInteger(), nullable=False),
        sa.Column('furachi_id', sa.BigInteger(), nullable=True),
        sa.Column('cargo_type', sa.String(100), nullable=False),
        sa.Column('from_city', sa.String(100), nullable=False),
        sa.Column('to_city', sa.String(100), nullable=False),
        sa.Column('weight_kg', sa.String(50), nullable=True),
        sa.Column('price', sa.String(50), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('status', sa.String(30), nullable=True, server_default='pending'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.ForeignKeyConstraint(['yukchi_id'], ['users.id']),
        sa.ForeignKeyConstraint(['furachi_id'], ['users.id']),
        sa.PrimaryKeyConstraint('id', name=op.f('pk_orders'))
    )
    op.create_index('ix_orders_id', 'orders', ['id'], unique=False)
    op.create_index('ix_orders_yukchi_id', 'orders', ['yukchi_id'], unique=False)
    op.create_index('ix_orders_furachi_id', 'orders', ['furachi_id'], unique=False)
    op.create_index('ix_orders_status', 'orders', ['status'], unique=False)


def downgrade() -> None:
    op.drop_index('ix_orders_status', table_name='orders')
    op.drop_index('ix_orders_furachi_id', table_name='orders')
    op.drop_index('ix_orders_yukchi_id', table_name='orders')
    op.drop_index('ix_orders_id', table_name='orders')
    op.drop_table('orders')

    op.drop_column('users', 'cargo_type')
    op.drop_column('users', 'to_routes')
    op.drop_column('users', 'from_city')
    op.drop_column('users', 'capacity')
    op.drop_column('users', 'truck_type')
    op.drop_column('users', 'is_profile_complete')
    op.drop_column('users', 'role')
