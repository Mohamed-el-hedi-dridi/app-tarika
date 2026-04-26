import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Familles de polices arabes calligraphiques disponibles
enum ArabicFont {
  scheherazade, // النسخ القرآني — خط شهرزاد
  amiri, //        الخط الأميري
  lateef, //       خط اللطيف الإسلامي
}

extension ArabicFontExt on ArabicFont {
  String get displayName {
    switch (this) {
      case ArabicFont.scheherazade:
        return 'النسخ القرآني';
      case ArabicFont.amiri:
        return 'الخط الأميري';
      case ArabicFont.lateef:
        return 'خط اللطيف';
    }
  }
}

class ReadingSettingsProvider extends ChangeNotifier {
  static const _kFontSize = 'r_font_size';
  static const _kTachkil = 'r_tachkil';
  static const _kFontIdx = 'r_font_idx';

  double _fontSize = 19.0;
  bool _showTachkil = true;
  ArabicFont _font = ArabicFont.scheherazade;

  double get fontSize => _fontSize;
  bool get showTachkil => _showTachkil;
  ArabicFont get font => _font;

  ReadingSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_kFontSize) ?? 19.0;
    _showTachkil = prefs.getBool(_kTachkil) ?? true;
    final idx = prefs.getInt(_kFontIdx) ?? 0;
    _font = ArabicFont.values[idx.clamp(0, ArabicFont.values.length - 1)];
    notifyListeners();
  }

  Future<void> setFontSize(double v) async {
    _fontSize = v.clamp(14.0, 30.0);
    (await SharedPreferences.getInstance()).setDouble(_kFontSize, _fontSize);
    notifyListeners();
  }

  Future<void> setTachkil(bool v) async {
    _showTachkil = v;
    (await SharedPreferences.getInstance()).setBool(_kTachkil, v);
    notifyListeners();
  }

  Future<void> setFont(ArabicFont f) async {
    _font = f;
    (await SharedPreferences.getInstance()).setInt(_kFontIdx, f.index);
    notifyListeners();
  }

  /// Supprime les signes diacritiques arabes (تشكيل) si désactivé
  String processText(String text) {
    if (_showTachkil) return text;
    return text.replaceAll(
      RegExp(
        r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]',
      ),
      '',
    );
  }

  /// TextStyle selon la police et la taille sélectionnées
  TextStyle readingStyle({double? size, Color color = AppTheme.darkBrown}) {
    final s = size ?? _fontSize;
    switch (_font) {
      case ArabicFont.amiri:
        return GoogleFonts.amiri(fontSize: s, color: color, height: 2.2);
      case ArabicFont.lateef:
        return GoogleFonts.lateef(fontSize: s, color: color, height: 2.3);
      case ArabicFont.scheherazade:
        return GoogleFonts.scheherazadeNew(
          fontSize: s,
          color: color,
          height: 2.5,
        );
    }
  }
}
