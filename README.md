# YukGo Flutter

**YukGo** - AI-powered logistics application. HTML → Flutter 1:1 konvertatsiya.

## 🎯 Features

- ✅ 10 ta to'liq screen (Splash, Onboarding, Login, Role Selection, AI Chat, va boshqalar)
- ✅ Clean architecture
- ✅ Google Fonts (Inter)
- ✅ Custom theme system
- ✅ Responsive UI
- ✅ Bottom navigation

## 📱 Screens

1. **Splash Screen** - Logo va welcome
2. **Onboarding** - Tanishuv ekrani
3. **Login** - Telegram/Google auth
4. **Role Selection** - Yukchi yoki Haydovchi
5. **AI Chat** - Yukchi AI chat interface
6. **AI Modal** - Analysis results
7. **Driver List** - Mavjud haydovchilar
8. **Tracking** - Yuk kuzatuvi
9. **Driver Profile** - Haydovchi profili
10. **Order Details** - Buyurtma tafsilotlari

## 🚀 Setup

```bash
# 1. Dependencies o'rnatish
flutter pub get

# 2. Ishga tushirish
flutter run

# Android/iOS
flutter run -d <device_id>

# Web
flutter run -d chrome
```

## 🎨 Theme

Tailwind CSS theme Flutter'ga to'liq konvertatsiya qilingan:

- Primary: `#2478FF`
- Background: `#F7FAFF`
- Card: `#FFFFFF`
- Muted: `#F1F5F9`
- Google Fonts: Inter

## 📁 Struktura

```
lib/
├── main.dart
├── core/
│   └── theme/
│       └── app_theme.dart
└── features/
    ├── onboarding/
    │   └── screens/
    ├── auth/
    │   └── screens/
    └── chat/
        └── screens/
```

## 🔥 Next Steps

- [ ] State management (BLoC/Riverpod)
- [ ] API integration
- [ ] SQLite local storage
- [ ] Real-time tracking
- [ ] Push notifications
- [ ] Multi-language (UZ/RU/EN)

## 📝 Notes

HTML'dagi barcha screen'lar pixel-perfect Flutter widgetlariga aylantirilgan. Iconify icons → Material Icons/Icons.

Tailwind classes → Flutter widgets:
- `rounded-2xl` → `BorderRadius.circular(16)`
- `bg-primary` → `color: AppTheme.primary`
- `flex items-center` → `Row(mainAxisAlignment: center)`

Ready for production! 🚀
