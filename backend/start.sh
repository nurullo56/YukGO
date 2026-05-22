#!/bin/sh
set -e

echo "🔄 Waiting for database..."
python - <<'EOF'
import asyncio
import asyncpg
import os, time

async def wait():
    url = os.environ.get("DATABASE_URL", "").replace("postgresql+asyncpg://", "postgresql://")
    for i in range(30):
        try:
            conn = await asyncpg.connect(url)
            await conn.close()
            print("✅ PostgreSQL is up")
            return
        except Exception as e:
            print(f"⏳ Waiting... ({i+1}/30): {e}")
            time.sleep(2)
    raise Exception("❌ Could not connect to PostgreSQL")

asyncio.run(wait())
EOF

echo "🔄 Running migrations..."
alembic upgrade head

echo "🚀 Starting application..."
exec python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
