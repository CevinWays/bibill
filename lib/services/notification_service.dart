import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Android Settings
    // Note: Ensure 'ic_launcher' exists in android/app/src/main/res/drawable/ or mipmap
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleForSubscription(Subscription subscription) async {
    final nextRenewal = subscription.nextRenewal();

    // Schedule for each reminder
    for (int daysBefore in subscription.reminders) {
      final scheduledDate = nextRenewal.subtract(Duration(days: daysBefore));

      // If the scheduled time is in the past, skip it (or schedule for the NEXT cycle if were advanced)
      // For MVP, we only schedule if it's in the future.
      if (scheduledDate.isBefore(DateTime.now())) continue;

      // Unique ID for this notification: Hash of Sub ID + daysBefore
      final notificationId = (subscription.id.hashCode + daysBefore)
          .abs(); // Ensure positive

      await _scheduleNotification(
        id: notificationId,
        title: 'Pengingat Tagihan ${subscription.name}',
        body:
            'Tagihan ${subscription.name} sebesar Rp${subscription.price.toStringAsFixed(0)} akan jatuh tempo dalam $daysBefore hari.',
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> requestPermissions() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (result != null && result) {
      // Permission granted
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'subscription_reminders_v2',
          'Subscription Reminders',
          channelDescription: 'Notifications for subscription renewals',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      888,
      'Test Notification',
      'This is a test notification from Bibill.',
      notificationDetails,
      payload: 'item x',
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders_v2',
          'Subscription Reminders',
          channelDescription: 'Notifications for subscription renewals',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelForSubscription(Subscription subscription) async {
    // We assume the standard reminders are 7 and 1. If we allow custom reminders later,
    // we might need to store notification IDs or cancel all reasonable possibilities.
    for (int daysBefore in [1, 7]) {
      final notificationId = (subscription.id.hashCode + daysBefore).abs();
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }
}
