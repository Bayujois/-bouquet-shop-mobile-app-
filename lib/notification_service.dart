import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initializationSettings);

    // Initialize timezone data once
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC')); // fallback; adjust if needed

    _initialized = true;
  }

  Future<void> requestAndroidPermissionIfNeeded() async {
    await init();
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.areNotificationsEnabled();
      if (granted == false) {
        await androidImpl.requestNotificationsPermission();
      }
    }
  }

  Future<void> scheduleNotesReminder({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    await init();

    final androidDetails = AndroidNotificationDetails(
      'notes_reminder_channel',
      'Notes Reminders',
      channelDescription: 'Pengingat catatan bisnis setiap beberapa hari',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    final details = NotificationDetails(android: androidDetails);

    // Cancel previous with same id to avoid duplicates.
    await _plugin.cancel(id);

    final tzDate = tz.TZDateTime.from(dateTime, tz.local);
    await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null);
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
