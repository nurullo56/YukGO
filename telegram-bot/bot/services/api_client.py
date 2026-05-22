"""
Backend API bilan aloqa
"""
import aiohttp
from typing import Optional, Dict, Any
from bot.config import settings
import logging

logger = logging.getLogger(__name__)


class BackendAPIClient:
    """Backend API client"""
    
    def __init__(self):
        self.base_url = settings.BACKEND_URL
        self.timeout = aiohttp.ClientTimeout(total=30)
    
    async def verify_phone(
        self,
        token: str,
        telegram_id: int,
        phone: str,
        first_name: Optional[str] = None,
        last_name: Optional[str] = None,
        username: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Telefon raqamni backend'ga yuborish
        """
        url = f"{self.base_url}/api/v1/auth/verify"
        
        payload = {
            "token": token,
            "telegram_id": telegram_id,
            "phone": phone,
            "first_name": first_name,
            "last_name": last_name,
            "username": username
        }
        
        try:
            async with aiohttp.ClientSession(timeout=self.timeout) as session:
                async with session.post(url, json=payload) as response:
                    if response.status == 200:
                        data = await response.json()
                        logger.info(f"✅ Phone verified for user {telegram_id}")
                        return data
                    else:
                        error = await response.json()
                        logger.error(f"❌ API Error: {error}")
                        return None
        except aiohttp.ClientError as e:
            logger.error(f"❌ Network error: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Unexpected error: {e}")
            return None


# Singleton instance
api_client = BackendAPIClient()