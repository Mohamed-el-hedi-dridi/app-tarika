import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationPrefs {
  final bool morningEnabled;
  final int morningHour;
  final int morningMinute;
  final bool eveningEnabled;
  final int eveningHour;
  final int eveningMinute;

  const NotificationPrefs({
    required this.morningEnabled,
    required this.morningHour,
    required this.morningMinute,
    required this.eveningEnabled,
    required this.eveningHour,
    required this.eveningMinute,
  });
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const int _morningId = 1001;
  static const int _eveningId = 1002;

  static const String _kMorningEnabled = 'notif_morning_enabled';
  static const String _kMorningHour    = 'notif_morning_hour';
  static const String _kMorningMin     = 'notif_morning_min';
  static const String _kEveningEnabled = 'notif_evening_enabled';
  static const String _kEveningHour    = 'notif_evening_hour';
  static const String _kEveningMin     = 'notif_evening_min';

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Replanifier les notifications existantes au démarrage
    final prefs = await loadPrefs();
    await scheduleMorning(
      enabled: prefs.morningEnabled,
      hour: prefs.morningHour,
      minute: prefs.morningMinute,
    );
    await scheduleEvening(
      enabled: prefs.eveningEnabled,
      hour: prefs.eveningHour,
      minute: prefs.eveningMinute,
    );
  }

  Future<NotificationPrefs> loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    return NotificationPrefs(
      morningEnabled: p.getBool(_kMorningEnabled) ?? false,
      morningHour:    p.getInt(_kMorningHour)    ?? 5,
      morningMinute:  p.getInt(_kMorningMin)     ?? 30,
      eveningEnabled: p.getBool(_kEveningEnabled) ?? false,
      eveningHour:    p.getInt(_kEveningHour)    ?? 19,
      eveningMinute:  p.getInt(_kEveningMin)     ?? 30,
    );
  }

  Future<void> _savePrefs(NotificationPrefs prefs) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMorningEnabled, prefs.morningEnabled);
    await p.setInt(_kMorningHour,    prefs.morningHour);
    await p.setInt(_kMorningMin,     prefs.morningMinute);
    await p.setBool(_kEveningEnabled, prefs.eveningEnabled);
    await p.setInt(_kEveningHour,    prefs.eveningHour);
    await p.setInt(_kEveningMin,     prefs.eveningMinute);
  }

  Future<void> scheduleMorning({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(_morningId);
    if (!enabled) return;
    await _plugin.zonedSchedule(
      _morningId,
      'ورد الصباح 🌅',
      'حان وقت ورد الصباح بعد صلاة الصبح',
      _nextInstanceOf(hour, minute),
      _notifDetails('morning'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  Future<void> scheduleEvening({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(_eveningId);
    if (!enabled) return;
    await _plugin.zonedSchedule(
      _eveningId,
      'ورد المساء 🌙',
      'حان وقت ورد المساء بعد صلاة المغرب',
      _nextInstanceOf(hour, minute),
      _notifDetails('evening'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  Future<void> saveAndSchedule(NotificationPrefs prefs) async {
    await _savePrefs(prefs);
    await scheduleMorning(
      enabled: prefs.morningEnabled,
      hour: prefs.morningHour,
      minute: prefs.morningMinute,
    );
    await scheduleEvening(
      enabled: prefs.eveningEnabled,
      hour: prefs.eveningHour,
      minute: prefs.eveningMinute,
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _notifDetails(String channel) {
    final android = AndroidNotificationDetails(
      'tarika_$channel',
      channel == 'morning' ? 'ورد الصباح' : 'ورد المساء',
      channelDescription: channel == 'morning'
          ? 'تذكير بورد الصباح'
          : 'تذكير بورد المساء',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    return NotificationDetails(android: android, iOS: ios);
  }
}
