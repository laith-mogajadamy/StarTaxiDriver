import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Initialize notification service
  Future<void> initialize() async {
    // Initialize local notifications
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _firebaseMessaging.subscribeToTopic('driver');
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true, // Request alert permission on iOS
      requestBadgePermission: true, // Request badge permission on iOS
      requestSoundPermission: true, // Request sound permission on iOS
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: _onSelectNotification,
      // Handle tap on notifications
    );

    // Request for permissions if iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Handle background notifications
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Handle terminated state notifications (app killed)
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _firebaseMessaging.getInitialMessage().then(_onInitialMessage);
    }

    // Get the device token
    _getDeviceToken();
  }

  // Handle incoming foreground messages
  Future<void> _onMessage(RemoteMessage message) async {
    print('Foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      _showNotification(message);
    }
  }

  // Handle background messages
  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');
    if (message.notification != null) {
      _showNotification(message);
    }
  }

  // Handle terminated state messages (app killed)
  Future<void> _onInitialMessage(RemoteMessage? message) async {
    if (message != null) {
      print('Terminated state message: ${message.notification?.title}');
      if (message.notification != null) {
        _showNotification(message);
      }
    }
  }

  // Display the notification
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id2',
      'channel_name2',
      importance: Importance.max,
      priority: Priority.max,
      visibility: NotificationVisibility.public,
      playSound: true,
    );

    // iOS-specific notification details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  // Future<void> _onSelectNotification(String? payload) async {
  //   print('Notification tapped with payload: $payload');
  //   // Add your navigation logic here if needed
  // }

  // Get the device token for push notifications
  Future<void> _getDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = await _firebaseMessaging.getToken();
    prefs.setString('device_token', token!);
    print('Device Token: $token');
  }
}
