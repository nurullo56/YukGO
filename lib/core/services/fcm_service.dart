import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'yukgo_main',
    'YukGo Bildirishnomalar',
    description: 'Buyurtma va chat xabarlari',
    importance: Importance.high,
  );

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    if (Platform.isAndroid) {
      await _localNotif
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showLocal);

    await _uploadToken();
    _messaging.onTokenRefresh.listen((_) => _uploadToken());
  }

  static Future<String?> getToken() => _messaging.getToken();

  static Future<void> _uploadToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await ApiService.saveFcmToken(token);
      }
    } catch (_) {}
  }

  static void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _localNotif.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
