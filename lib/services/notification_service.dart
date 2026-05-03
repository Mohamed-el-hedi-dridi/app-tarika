import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'prayer_times_service.dart';

class NotificationPrefs {
  final bool morningEnabled;
  final int morningHour;
  final int morningMinute;
  final bool eveningEnabled;
  final int eveningHour;
  final int eveningMinute;
  final bool duhaEnabled;
  final bool fajrWirdEnabled;
  final bool maghribWirdEnabled;

  const NotificationPrefs({
    required this.morningEnabled,
    required this.morningHour,
    required this.morningMinute,
    required this.eveningEnabled,
    required this.eveningHour,
    required this.eveningMinute,
    this.duhaEnabled = false,
    this.fajrWirdEnabled = false,
    this.maghribWirdEnabled = false,
    this.kahfEnabled = false,
    this.kahfHour = 8,
    this.kahfMinute = 0,
  });

  final bool kahfEnabled;
  final int  kahfHour;
  final int  kahfMinute;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const int _morningId = 1001;
  static const int _eveningId = 1002;
  static const int _kahfId   = 1003;
  static const int _duhaBase        = 2000;
  static const int _fajrWirdBase    = 2100;
  static const int _maghribWirdBase = 2200;
  static const int _prayerDays      = 14;

  static const String _kMorningEnabled = 'notif_morning_enabled';
  static const String _kMorningHour    = 'notif_morning_hour';
  static const String _kMorningMin     = 'notif_morning_min';
  static const String _kEveningEnabled = 'notif_evening_enabled';
  static const String _kEveningHour    = 'notif_evening_hour';
  static const String _kEveningMin     = 'notif_evening_min';
  static const String _kDuhaEnabled         = 'notif_duha_enabled';
  static const String _kFajrWirdEnabled     = 'notif_fajr_wird_enabled';
  static const String _kMaghribWirdEnabled  = 'notif_maghrib_wird_enabled';
  static const String _kKahfEnabled         = 'notif_kahf_enabled';
  static const String _kKahfHour            = 'notif_kahf_hour';
  static const String _kKahfMin             = 'notif_kahf_min';

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

    await scheduleKahf(
      enabled: prefs.kahfEnabled,
      hour: prefs.kahfHour,
      minute: prefs.kahfMinute,
    );

    if (prefs.duhaEnabled || prefs.fajrWirdEnabled || prefs.maghribWirdEnabled) {
      try {
        final days = await PrayerTimesService.instance.getNextDays(_prayerDays);
        await _schedulePrayerAlarms(
          duhaEnabled: prefs.duhaEnabled,
          fajrWirdEnabled: prefs.fajrWirdEnabled,
          maghribWirdEnabled: prefs.maghribWirdEnabled,
          days: days,
        );
      } catch (_) {}
    }
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
      duhaEnabled:         p.getBool(_kDuhaEnabled)        ?? false,
      fajrWirdEnabled:     p.getBool(_kFajrWirdEnabled)    ?? false,
      maghribWirdEnabled:  p.getBool(_kMaghribWirdEnabled) ?? false,
      kahfEnabled:         p.getBool(_kKahfEnabled)        ?? false,
      kahfHour:            p.getInt(_kKahfHour)            ?? 8,
      kahfMinute:          p.getInt(_kKahfMin)             ?? 0,
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
    await p.setBool(_kDuhaEnabled,        prefs.duhaEnabled);
    await p.setBool(_kFajrWirdEnabled,    prefs.fajrWirdEnabled);
    await p.setBool(_kMaghribWirdEnabled, prefs.maghribWirdEnabled);
    await p.setBool(_kKahfEnabled,        prefs.kahfEnabled);
    await p.setInt(_kKahfHour,            prefs.kahfHour);
    await p.setInt(_kKahfMin,             prefs.kahfMinute);
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

  Future<void> scheduleKahf({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(_kahfId);
    if (!enabled) return;
    await _plugin.zonedSchedule(
      _kahfId,
      'سورة الكهف 📖',
      'يوم الجمعة — لا تنسَ قراءة سورة الكهف',
      _nextFridayAt(hour, minute),
      _notifDetails('kahf'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  /// Prochain vendredi à l'heure donnée (DateTime.friday == 5)
  tz.TZDateTime _nextFridayAt(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // Avancer jusqu'au prochain vendredi
    while (candidate.weekday != DateTime.friday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
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
    await scheduleKahf(
      enabled: prefs.kahfEnabled,
      hour: prefs.kahfHour,
      minute: prefs.kahfMinute,
    );
  }

  Future<void> saveAndSchedulePrayerAlarms(NotificationPrefs prefs) async {
    await _savePrefs(prefs);
    await _cancelAllPrayerAlarms();

    // Kahf (hebdomadaire — indépendant des prières calculées)
    await scheduleKahf(
      enabled: prefs.kahfEnabled,
      hour: prefs.kahfHour,
      minute: prefs.kahfMinute,
    );

    if (!prefs.duhaEnabled && !prefs.fajrWirdEnabled && !prefs.maghribWirdEnabled) {
      return;
    }

    final days = await PrayerTimesService.instance.getNextDays(_prayerDays);
    await _schedulePrayerAlarms(
      duhaEnabled: prefs.duhaEnabled,
      fajrWirdEnabled: prefs.fajrWirdEnabled,
      maghribWirdEnabled: prefs.maghribWirdEnabled,
      days: days,
    );
  }

  Future<void> _cancelAllPrayerAlarms() async {
    for (int i = 0; i < _prayerDays; i++) {
      await _plugin.cancel(_duhaBase + i);
      await _plugin.cancel(_fajrWirdBase + i);
      await _plugin.cancel(_maghribWirdBase + i);
    }
  }

  Future<void> _schedulePrayerAlarms({
    required bool duhaEnabled,
    required bool fajrWirdEnabled,
    required bool maghribWirdEnabled,
    required List<DayPrayerTimes> days,
  }) async {
    final now = DateTime.now();
    int duhaCount = 0, fajrCount = 0, maghribCount = 0;

    for (final day in days) {
      if (duhaEnabled && day.duha.isAfter(now) && duhaCount < _prayerDays) {
        await _plugin.zonedSchedule(
          _duhaBase + duhaCount,
          'صلاة الضحى ☀️',
          'حان وقت صلاة الضحى',
          tz.TZDateTime.from(day.duha, tz.local),
          _notifDetails('duha'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
        duhaCount++;
      }

      if (fajrWirdEnabled && day.fajrWird.isAfter(now) && fajrCount < _prayerDays) {
        await _plugin.zonedSchedule(
          _fajrWirdBase + fajrCount,
          'ورد الصباح 🌅',
          'حان وقت ورد الصباح — ٣٠ دقيقة بعد الفجر',
          tz.TZDateTime.from(day.fajrWird, tz.local),
          _notifDetails('morning'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
        fajrCount++;
      }

      if (maghribWirdEnabled && day.maghribWird.isAfter(now) && maghribCount < _prayerDays) {
        await _plugin.zonedSchedule(
          _maghribWirdBase + maghribCount,
          'ورد المساء 🌙',
          'حان وقت ورد المساء — ٢٠ دقيقة بعد المغرب',
          tz.TZDateTime.from(day.maghribWird, tz.local),
          _notifDetails('evening'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
        maghribCount++;
      }
    }
  }

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
    String channelName;
    String channelDesc;
    switch (channel) {
      case 'morning':
        channelName = 'ورد الصباح';
        channelDesc = 'تذكير بورد الصباح';
      case 'evening':
        channelName = 'ورد المساء';
        channelDesc = 'تذكير بورد المساء';
      case 'duha':
        channelName = 'صلاة الضحى';
        channelDesc = 'تذكير بصلاة الضحى';
      case 'kahf':
        channelName = 'سورة الكهف';
        channelDesc = 'تذكير بقراءة سورة الكهف يوم الجمعة';
      default:
        channelName = channel;
        channelDesc = channel;
    }
    final android = AndroidNotificationDetails(
      'tarika_$channel',
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    return NotificationDetails(android: android, iOS: ios);
  }
}
