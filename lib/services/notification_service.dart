import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:timezone/browser.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await _requestPermissions();
    
    _isInitialized = true;
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();
    
    // For Android 13+ (API 33+), request POST_NOTIFICATIONS permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Show rain alert notification
  Future<void> showRainAlert({
    required String title,
    required String body,
    String? location,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'rain_alerts',
      'Rain Alerts',
      channelDescription: 'Notifications for incoming rain',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3B82F6),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // notification id
      title,
      body,
      platformDetails,
    );
  }

  // Show weather update notification
  Future<void> showWeatherUpdate({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weather_updates',
      'Weather Updates',
      channelDescription: 'General weather updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF06B6D4),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2, // notification id
      title,
      body,
      platformDetails,
    );
  }

  // Schedule rain alert notification
  Future<void> scheduleRainAlert({
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'rain_alerts',
      'Rain Alerts',
      channelDescription: 'Notifications for incoming rain',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3B82F6),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // await _notifications.zonedSchedule(
    //   3, // notification id
    //   title,
    //   body,
    //   TZDateTime.from(scheduledTime, scheduledTime.timeZoneName == 'UTC' ? getLocation('UTC') : getLocation("America/New_York")),
    //   platformDetails,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    // );
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}