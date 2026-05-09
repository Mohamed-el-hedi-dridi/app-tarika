import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/prayer_times_service.dart';

/// Suit la complétion du wird quotidien (ورد الصباح / ورد المساء)
/// et du wird aam (الورد العام — صباح / مساء).
///
/// Logique de périodes :
///   – ورد الصباح  → se réinitialise après chaque Fajr
///   – ورد المساء  → se réinitialise après chaque Maghrib
class WirdCompletionProvider extends ChangeNotifier {
  // الوظيفة
  static const _kSobe7Done  = 'wird_sobe7_done';
  static const _kMasa2Done  = 'wird_masa2_done';
  // الورد العام
  static const _kAamSobe7Done = 'wird_aam_sobe7_done';
  static const _kAamMasa2Done = 'wird_aam_masa2_done';

  // Clés de période séparées
  static const _kLastSobhPeriod    = 'wird_last_sobh_period';
  static const _kLastMaghribPeriod = 'wird_last_maghrib_period';

  bool _isSobe7Done    = false;
  bool _isMasa2Done    = false;
  bool _isAamSobe7Done = false;
  bool _isAamMasa2Done = false;
  String _lastSobhPeriod    = '';
  String _lastMaghribPeriod = '';

  bool get isSobe7Done    => _isSobe7Done;
  bool get isMasa2Done    => _isMasa2Done;
  bool get isAamSobe7Done => _isAamSobe7Done;
  bool get isAamMasa2Done => _isAamMasa2Done;
  bool get isAllDone      => _isSobe7Done && _isMasa2Done;
  bool get isAamAllDone   => _isAamSobe7Done && _isAamMasa2Done;

  WirdCompletionProvider() {
    _load();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Clé période Sobh : "YYYY-MM-DD" ──────────────────────────────────────
  // Après Fajr  → aujourd'hui (nouvelle session matinale)
  // Avant Fajr  → hier      (encore dans la nuit précédente)
  Future<String> _sobhPeriodKey() async {
    try {
      final times = await PrayerTimesService.instance.getToday();
      final now   = DateTime.now();
      final d     = now.isAfter(times.fajr) ? now : now.subtract(const Duration(days: 1));
      return _fmt(d);
    } catch (_) {
      return _fmt(DateTime.now());
    }
  }

  // ── Clé période Maghrib : "YYYY-MM-DD" ───────────────────────────────────
  // Après Maghrib → aujourd'hui (nouvelle session vespérale)
  // Avant Maghrib → hier      (encore dans la session d'hier soir)
  Future<String> _maghribPeriodKey() async {
    try {
      final times = await PrayerTimesService.instance.getToday();
      final now   = DateTime.now();
      final d     = now.isAfter(times.maghrib) ? now : now.subtract(const Duration(days: 1));
      return _fmt(d);
    } catch (_) {
      return _fmt(DateTime.now());
    }
  }

  // ── Chargement initial ────────────────────────────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final sobhKey    = await _sobhPeriodKey();
    final maghribKey = await _maghribPeriodKey();
    _lastSobhPeriod    = prefs.getString(_kLastSobhPeriod)    ?? '';
    _lastMaghribPeriod = prefs.getString(_kLastMaghribPeriod) ?? '';

    bool changed = false;

    // Reset matin si nouvelle session Fajr
    if (_lastSobhPeriod != sobhKey) {
      _isSobe7Done    = false;
      _isAamSobe7Done = false;
      _lastSobhPeriod = sobhKey;
      changed = true;
    } else {
      _isSobe7Done    = prefs.getBool(_kSobe7Done)    ?? false;
      _isAamSobe7Done = prefs.getBool(_kAamSobe7Done) ?? false;
    }

    // Reset soir si nouvelle session Maghrib
    if (_lastMaghribPeriod != maghribKey) {
      _isMasa2Done    = false;
      _isAamMasa2Done = false;
      _lastMaghribPeriod = maghribKey;
      changed = true;
    } else {
      _isMasa2Done    = prefs.getBool(_kMasa2Done)    ?? false;
      _isAamMasa2Done = prefs.getBool(_kAamMasa2Done) ?? false;
    }

    if (changed) await _persist(prefs);
    notifyListeners();
  }

  /// À appeler lors de la reprise de l'app (onResume) pour vérifier le reset.
  Future<void> checkReset() async {
    final prefs = await SharedPreferences.getInstance();
    final sobhKey    = await _sobhPeriodKey();
    final maghribKey = await _maghribPeriodKey();
    bool changed = false;

    if (sobhKey != _lastSobhPeriod) {
      _isSobe7Done    = false;
      _isAamSobe7Done = false;
      _lastSobhPeriod = sobhKey;
      changed = true;
    }

    if (maghribKey != _lastMaghribPeriod) {
      _isMasa2Done    = false;
      _isAamMasa2Done = false;
      _lastMaghribPeriod = maghribKey;
      changed = true;
    }

    if (changed) {
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
    await prefs.setString(_kLastSobhPeriod,    _lastSobhPeriod);
    await prefs.setString(_kLastMaghribPeriod, _lastMaghribPeriod);
  }
}
