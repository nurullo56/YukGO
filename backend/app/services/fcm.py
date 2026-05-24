"""
Firebase Cloud Messaging — Firebase Admin SDK orqali push yuborish
"""
import os
import logging

logger = logging.getLogger(__name__)

_SERVICE_ACCOUNT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    "firebase-service-account.json"
)

_app = None

def _get_app():
    global _app
    if _app is not None:
        return _app
    try:
        import firebase_admin
        from firebase_admin import credentials
        if not os.path.exists(_SERVICE_ACCOUNT):
            logger.warning(f"FCM: service account not found at {_SERVICE_ACCOUNT}")
            return None
        cred = credentials.Certificate(_SERVICE_ACCOUNT)
        _app = firebase_admin.initialize_app(cred)
        logger.info("FCM: Firebase Admin initialized")
    except Exception as e:
        logger.error(f"FCM init error: {e}")
        _app = None
    return _app


async def send_push(*, token: str, title: str, body: str, data: dict = None) -> bool:
    """Firebase Admin SDK orqali push notification yuborish."""
    if not token:
        return False
    try:
        from firebase_admin import messaging
        app = _get_app()
        if app is None:
            return False

        msg = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            android=messaging.AndroidConfig(priority="high"),
            token=token,
        )
        response = messaging.send(msg)
        logger.info(f"FCM sent: {response}")
        return True
    except Exception as e:
        logger.error(f"FCM send error: {e}")
        return False
