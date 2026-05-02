import 'dart:convert';
import 'package:flutter/services.dart';

// ──────────────────────────────────────────────────────────────
// Model
// ──────────────────────────────────────────────────────────────
class QuranVerse {
  final String verseKey;
  final int surahNumber;
  final int verseNumber;
  final String text;
  final String surahNameAr;

  const QuranVerse({
    required this.verseKey,
    required this.surahNumber,
    required this.verseNumber,
    required this.text,
    this.surahNameAr = '',
  });
}

// ──────────────────────────────────────────────────────────────
// Service  (données locales — رواية ورش، بيانات مجمع الملك فهد)
// ──────────────────────────────────────────────────────────────
class QuranService {
  static const String _assetPath =
      'assets/quran/data/quran_warsh_hizb.json';

  /// Cache global : hizb → liste d'ayats (chargé une seule fois)
  static Map<int, List<QuranVerse>>? _cache;

  /// Charge le JSON d'assets et peuple le cache (idempotent)
  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> data =
        jsonDecode(raw) as Map<String, dynamic>;
    _cache = {};
    data.forEach((key, value) {
      final hizb = int.parse(key);
      final list = (value as List<dynamic>).map((v) {
        final m = v as Map<String, dynamic>;
        final s = m['s'] as int;
        final a = m['a'] as int;
        return QuranVerse(
          verseKey: '$s:$a',
          surahNumber: s,
          verseNumber: a,
          text: m['t'] as String,
          surahNameAr: m['sn'] as String? ?? '',
        );
      }).toList();
      _cache![hizb] = list;
    });
  }

  /// أسماء السور الـ 114 باللغة العربية
  static const List<String> _surahNames = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة',
    'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
    'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان',
    'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر',
    'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
    'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
    'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
    'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن',
    'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق',
    'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
    'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
    'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
    'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج',
    'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين',
    'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
    'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل',
    'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
    'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  /// اسم السورة برقمها (1–114)
  static String surahName(int n) =>
      (n >= 1 && n <= 114) ? _surahNames[n - 1] : 'سورة $n';

  /// هل تبدأ السورة بالبسملة (جميع السور ما عدا التوبة والفاتحة)
  /// الفاتحة لها البسملة كأول آية فعلاً في البيانات
  static bool hasSeparateBasmala(int surahNumber) =>
      surahNumber != 1 && surahNumber != 9;

  /// جلب آيات حزب كامل من الأصول المحلية (بيانات ورش، مجمع الملك فهد)
  static Future<List<QuranVerse>> fetchHizb(int hizbNumber) async {
    await _ensureLoaded();
    return List<QuranVerse>.from(_cache![hizbNumber] ?? []);
  }
}
