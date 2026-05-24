# 🛠️ YukGo Loyihasini Tuzatish va Optimallashtirish Bo'yicha Yo'riqnoma

Ushbu qo'llanma YukGo loyihasining **Backend**, **Telegram Bot** va **Flutter** qismlaridagi xatoliklarni to'g'rilash va kodni optimallashtirish uchun tayyorlandi. Ertaga ushbu faylga qarab, tegishli joylarni copy-paste orqali osongina tuzatib chiqishingiz mumkin.

---

## 📂 MUNDARIJA
1. [FastAPI WebSocket DB Session Sizishini Tuzatish](#1-fastapi-websocket-db-session-sizishini-tuzatish)
2. [SQLite BigInteger Autoincrement Muammosini Tuzatish](#2-sqlite-biginteger-autoincrement-muammosini-tuzatish)
3. [Telegram Bot Router Ro'yxatdan O'tish Xatosini Tuzatish](#3-telegram-bot-router-royxatdan-otish-xatosini-tuzatish)
4. [Flutter RawKeyboardListener Memory Leak (Xotira Sizishi) Tuzatish](#4-flutter-rawkeyboardlistener-memory-leak-xotira-sizishi-tuzatish)
5. [Flutter WebSocket Reconnection (Cheksiz Sikl) Tuzatish](#5-flutter-websocket-reconnection-cheksiz-sikl-tuzatish)
6. [Flutter WebSocket Dinamik URL Tuzatish](#6-flutter-websocket-dinamik-url-tuzatish)

---

## 1. FastAPI WebSocket DB Session Sizishini Tuzatish

### 📍 Fayl manzili:
`backend/app/api/v1/endpoints/chat.py`

### ⚠️ Muammo:
WebSocket endpointda `db: AsyncSession = Depends(get_db)` ulanishi WebSocket ochiq turguncha bazadagi bitta connection'ni band qilib turadi. Bu database pool tugashiga olib keladi.

### 🛠️ Tuzatish:
Faylning eng yuqori qismida `Depends(get_db)` o'rniga `async_session_maker` ni import qiling va WebSocket handlerini qisqa muddatli session blocklari bilan almashtiring.

#### 🔄 O'zgartirish:
1. `backend/app/api/v1/endpoints/chat.py` faylining yuqori qismidagi importlar orasiga qo'shing:
```python
from app.db.session import async_session_maker
```

2. `chat_ws` WebSocket handlerini quyidagiga almashtiring (L60-L121):

**Eski kod o'rniga yangisi:**
```python
@router.websocket("/ws/{room_id}")
async def chat_ws(
    room_id: str,
    websocket: WebSocket,
    token: str = Query(...),
):
    # Authenticate (qisqa muddatli session yaratib tekshiramiz va yopamiz)
    async with async_session_maker() as db:
        try:
            user: User = await AuthService.get_current_user(token, db)
        except AuthError:
            await websocket.close(code=4001)
            return

    await manager.connect(room_id, user.id, websocket)
    logger.info(f"WS connected: user={user.id} room={room_id}")

    # Send last 50 messages on connect (qisqa muddatli session)
    async with async_session_maker() as db:
        history = await _get_history(room_id, db, limit=50)
    await websocket.send_json({"type": "history", "messages": history})

    try:
        while True:
            raw = await websocket.receive_text()
            data = json.loads(raw)
            content = (data.get("content") or "").strip()
            if not content:
                continue

            # Save to DB (har bir xabar kelganda yangi session ochib yopamiz)
            async with async_session_maker() as db:
                msg = Message(room_id=room_id, sender_id=user.id, content=content)
                db.add(msg)
                await db.commit()
                await db.refresh(msg)

                payload = {
                    "type": "message",
                    "id": msg.id,
                    "room_id": room_id,
                    "sender_id": user.id,
                    "sender_name": f"{user.first_name or ''} {user.last_name or ''}".strip() or "User",
                    "content": content,
                    "created_at": msg.created_at.isoformat(),
                }

                # Broadcast to others in room
                await manager.broadcast(room_id, payload, exclude_user=user.id)

                # Also echo back to sender
                await websocket.send_json(payload)

                # Push notification to offline users
                online = manager.online_users(room_id)
                await _push_to_offline(room_id, user, content, online, db)

    except WebSocketDisconnect:
        manager.disconnect(room_id, user.id)
        logger.info(f"WS disconnected: user={user.id} room={room_id}")
    except Exception as e:
        logger.error(f"WS error: {e}")
        manager.disconnect(room_id, user.id)
```

---

## 2. SQLite BigInteger Autoincrement Muammosini Tuzatish

### 📍 Fayl manzili:
`backend/app/db/models/order.py`

### ⚠️ Muammo:
SQLite database'da `BigInteger` primary key kolonnasi autoincrement bo'lmasligi mumkin. Bu yangi buyurtma yaratishda takrorlanuvchi ID xatoligini beradi.

### 🛠️ Tuzatish:
13-qatordagi `BigInteger` ni `Integer` ga o'zgartiring va `autoincrement=True` qo'shing.

#### 🔄 O'zgartirish:
```diff
-    id = Column(BigInteger, primary_key=True, index=True)
+    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
```

---

## 3. Telegram Bot Router Ro'yxatdan O'tish Xatosini Tuzatish

### 📍 Fayl manzili:
`telegram-bot/bot/main.py`

### ⚠️ Muammo:
`bot/handlers/auth.py` routeri import qilingan bo'lsa-da dispatcherga ulanmagan.

### 🛠️ Tuzatish:
Router import qilinmagan bo'lsa import qilib, `dp.include_router` ga qo'shing.

#### 🔄 O'zgartirish:
Faylning 9-qatorida:
```python
from bot.handlers import start, contact, auth  # auth ni ham import qilamiz
```

Faylning 34-qatorida:
```diff
     # Handlers
     dp.include_router(start.router)
     dp.include_router(contact.router)
+    dp.include_router(auth.router)
```

---

## 4. Flutter RawKeyboardListener Memory Leak (Xotira Sizishi) Tuzatish

### 📍 Fayl manzili:
`lib/features/auth/screens/telegram_otp_screen.dart`

### ⚠️ Muammo:
`_OtpBox` sinfida har safar build bo'lganda yangi `FocusNode()` obyekti yaratilib xotira to'lib qoladi.

### 🛠️ Tuzatish:
`RawKeyboardListener` ichidagi `focusNode: FocusNode()` ni shundoq ham pastdagi text field uchun boshqariladigan va yuqoridan kelayotgan `node` obyekti bilan almashtiring.

#### 🔄 O'zgartirish (Taxminan 259-qatorda):
```diff
   @override
   Widget build(BuildContext context) {
     return RawKeyboardListener(
       focusNode: FocusNode(), // <--- ESKI XAVFLI KOD
+      focusNode: node,        // <--- TO'G'RI VARIANT (o'zini node'ini ishlatadi)
       onKey: onKey,
       child: SizedBox(
```

---

## 5. Flutter WebSocket Reconnection (Cheksiz Sikl) Tuzatish

### 📍 Fayl manzili:
`lib/features/chat/screens/chat_screen.dart`

### ⚠️ Muammo:
Ulanish uzilganda har 3 soniyada to'xtovsiz ulanishga urinaverishi cheksiz loop hosil qilib batareyani tez tugatadi.

### 🛠️ Tuzatish:
Sekin-asta oshib boruvchi kechikish (Exponential Backoff) va takroriy ulanish mantig'ini qo'shing.

#### 🔄 O'zgartirish:
1. `_ChatScreenState` klassiga o'zgaruvchi qo'shing (taxminan 25-qatorlar atrofida):
```dart
  int _retryDelaySeconds = 3; // Ulanish kechikish vaqti
```

2. `_connect` funksiyasidagi muvaffaqiyatli ulanish bloki ichiga qayta tiklashni qo'shing (L50 atrofida):
```dart
      if (mounted) {
        setState(() {
          _connected = true;
          _connecting = false;
          _retryDelaySeconds = 3; // Reset retry delay
        });
      }
```

3. `_onDisconnect()` funksiyasini quyidagiga almashtiring (L73-L77):
```dart
  void _onDisconnect() {
    if (mounted) setState(() => _connected = false);
    
    // Exponential backoff bilan qayta ulanish (3s, 6s, 12s, 24s, 48s, maksimal 60s)
    Future.delayed(Duration(seconds: _retryDelaySeconds), () {
      if (mounted && !_connected && !_connecting) {
        _connect();
      }
    });
    
    // Kechikish vaqtini 2 barobar ko'paytiramiz, max 60 soniya
    _retryDelaySeconds = (_retryDelaySeconds * 2).clamp(3, 60);
  }
```

---

## 6. Flutter WebSocket Dinamik URL Tuzatish

### 📍 Birinchi fayl manzili:
`lib/core/services/api_service.dart`

#### 🛠️ O'zgartirish:
`ApiService` dagi shaxsiy (private) `_baseUrl` o'zgaruvchisini ochiq (public) qiling, shunda boshqa joydan dinamik WebSocket linkini olish mumkin bo'ladi.

```diff
-  static const String _baseUrl = 'https://api.smart-tools.uk/api/v1';
+  static const String baseUrl = 'https://api.smart-tools.uk/api/v1';
```
*(Eslatma: Fayl ichidagi barcha `_baseUrl` yozuvlarini ham `baseUrl` ga o'zgartirib chiqing)*

---

### 📍 Ikkinchi fayl manzili:
`lib/features/chat/screens/chat_screen.dart`

#### 🛠️ O'zgartirish:
Static URL o'rniga dinamik ravishda olingan URL'ni ishlating.

```dart
  // static const _wsBase = 'wss://api.smart-tools.uk/api/v1/chat/ws'; // ESKI KODNI O'CHIRING
  
  // Dinamik WebSocket Base URL getter'i:
  String get _wsBase {
    final httpUrl = ApiService.baseUrl;
    return httpUrl.replaceAll('https://', 'wss://').replaceAll('http://', 'ws://') + '/chat/ws';
  }
```

---

## 💡 Qo'shimcha Maslahat (Dead-Code'dan tozalash):
Ertaga barcha tuzatishlarni amalga oshirgach, **B-oqim (OTP kodli flow)** barqaror ishlashini ta'minlash uchun:
1. `backend/app/services/auth_service.py` faylidagi `verify_phone` funksiyasini saqlab qolgan holda, uning o'rniga OTP kodlik tizimga to'liq o'tishingiz mumkin.
2. Ishlatilmayotgan `telegram-bot/bot/services/api_client.py` kabi fayllarni bemalol o'chirib tashlashingiz mumkin, chunki hozirda kontakt yuborilganda u to'g'ridan-to'g'ri backenddagi `/phone-login` API'iga so'rov yubormoqda.

Sizga muvaffaqiyatli ish kunini tilayman! Ertaga barcha kodlarni bemalol o'zgartirib chiqing.
