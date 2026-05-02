import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/prayer_times_service.dart';

/// Suit la complétion du wird quotidien (ورد الصباح / ورد المساء)
/// et du wird aam (الورد العام — صباح / مساء).
///
/// Logique de période :
///   – Après Maghrib  → nouvelle période (date d'aujourd'hui)
///   – Avant Maghrib  → on est encore dans la période d'hier soir
/// → tous les wirds se réinitialisent à chaque Maghrib.
class WirdCompletionProvider extends ChangeNotifier {
  // الوظيفة
  static const _kSobe7Done  = 'wird_sobe7_done';
  static const _kMasa2Done  = 'wird_masa2_done';
  // الورد العام
  static const _kAamSobe7Done = 'wird_aam_sobe7_done';
  static const _kAamMasa2Done = 'wird_aam_masa2_done';

  static const _kLastPeriod = 'wird_last_period';

  bool _isSobe7Done    = false;
  bool _isMasa2Done    = false;
  bool _isAamSobe7Done = false;
  bool _isAamMasa2Done = false;
  String _lastPeriod   = '';

  bool get isSobe7Done    => _isSobe7Done;
  bool get isMasa2Done    => _isMasa2Done;
  bool get isAamSobe7Done => _isAamSobe7Done;
  bool get isAamMasa2Done => _isAamMasa2Done;
  bool get isAllDone      => _isSobe7Done && _isMasa2Done;
  bool get isAamAllDone   => _isAamSobe7Done && _isAamMasa2Done;

  WirdCompletionProvider() {
    _load();
  }

  // ── Clé de période : "YYYY-MM-DD" ────────────────────────────────────────
  // Avant Maghrib → la période est celle d'hier (cercle de hier soir)
  // Après Maghrib → la période est aujourd'hui (nouveau cercle)
  Future<String> _currentPeriodKey() async {
    try {
      final times = await PrayerTimesService.instance.getToday();
      final now   = DateTime.now();
      final d     = now.isAfter(times.maghrib) ? now : now.subtract(const Duration(days: 1));
      return _fmt(d);
    } catch (_) {
      // Fallback si le calcul des horaires échoue
      return _fmt(DateTime.now());
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Chargement initial ────────────────────────────────────────────────────
  Future<void> _load() async {
    final prefs  = await SharedPreferences.getInstance();
    final period = await _currentPeriodKey();
    _lastPeriod  = prefs.getString(_kLastPeriod) ?? '';

    if (_lastPeriod != period) {
      // Nouvelle période Maghrib → réinitialisation
      _isSobe7Done    = false;
      _isMasa2Done    = false;
      _isAamSobe7Done = false;
      _isAamMasa2Done = false;
      _lastPeriod     = period;
      await _persist(prefs);
    } else {
      _isSobe7Done    = prefs.getBool(_kSobe7Done)    ?? false;
      _isMasa2Done    = prefs.getBool(_kMasa2Done)    ?? false;
      _isAamSobe7Done = prefs.getBool(_kAamSobe7Done) ?? false;
      _isAamMasa2Done = prefs.getBool(_kAamMasa2Done) ?? false;
    }
    notifyListeners();
  }

  /// À appeler lors de la reprise de l'app (onResume) pour vérifier le reset.
  Future<void> checkReset() async {
    final prefs  = await SharedPreferences.getInstance();
    final period = await _currentPeriodKey();
    if (period != _lastPeriod) {
      _isSobe7Done    = false;
      _isMasa2Done    = false;
      _isAamSobe7Done = false;
      _isAamMasa2Done = false;
      _lastPeriod     = period;
      await _persist(prefs);
      notifyListeners();
    }
  }

  // ── Marquer / démarquer ───────────────────────────────────────────────────
  Future<void> setSobe7Done(bool value) async {
    _isSobe7Done = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSobe7Done, value);
    notifyListeners();
  }

  Future<void> setMasa2Done(bool value) async {
    _isMasa2Done = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMasa2Done, value);
    notifyListeners();
  }

  Future<void> setAamSobe7Done(bool value) async {
    _isAamSobe7Done = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAamSobe7Done, value);
    notifyListeners();
  }

  Future<void> setAamMasa2Done(bool value) async {
    _isAamMasa2Done = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAamMasa2Done, value);
    notifyListeners();
  }

  // ── Persistance ──────────────────────────────────────────────────────────
  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setBool(_kSobe7Done,    _isSobe7Done);
    await prefs.setBool(_kMasa2Done,    _isMasa2Done);
    await prefs.setBool(_kAamSobe7Done, _isAamSobe7Done);
    await prefs.setBool(_kAamMasa2Done, _isAamMasa2Done);
    await prefs.setString(_kLastPeriod, _lastPeriod);
  }
}
