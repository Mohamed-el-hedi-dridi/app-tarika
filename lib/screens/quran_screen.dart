import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_header.dart';
import '../providers/reading_settings_provider.dart';
import '../services/quran_service.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  int _currentHizb = 1;
  int _wirdStartHizb = 1;
  static const int totalHizbs = 60;
  static const int dailyHizbs = 4;

  static const _kCurrentHizb = 'q_current_hizb';
  static const _kWirdStart = 'q_wird_start';

  final Map<int, List<QuranVerse>> _cache = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHizb = prefs.getInt(_kCurrentHizb);
    final savedStart = prefs.getInt(_kWirdStart);
    if (!mounted) return;
    setState(() {
      _wirdStartHizb = (savedStart ?? 1).clamp(1, totalHizbs);
      _currentHizb = (savedHizb ?? _wirdStartHizb).clamp(1, totalHizbs);
    });
    _loadHizb(_currentHizb);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCurrentHizb, _currentHizb);
    await prefs.setInt(_kWirdStart, _wirdStartHizb);
  }

  Future<void> _loadHizb(int hizb) async {
    if (_cache.containsKey(hizb)) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final verses = await QuranService.fetchHizb(hizb);
      if (!mounted) return;
      setState(() {
        _cache[hizb] = verses;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'تعذّر تحميل القرآن الكريم.\nتأكد من سلامة ملفات التطبيق.';
      });
    }
  }

  void _selectHizb(int hizb) {
    if (hizb == _currentHizb) return;
    setState(() => _currentHizb = hizb);
    _loadHizb(hizb);
    _saveState();
  }

  Future<void> _changeWirdStart(int newStart) async {
    setState(() {
      _wirdStartHizb = newStart;
      _currentHizb = newStart;
    });
    _loadHizb(newStart);
    _saveState();
  }

  void _showPickWirdStart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WirdStartPickerSheet(
        currentStart: _wirdStartHizb,
        totalHizbs: totalHizbs,
        onSelected: (h) {
          Navigator.pop(context);
          _changeWirdStart(h);
        },
      ),
    );
  }

  void _showReadingSettings(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReadingSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Column(
        children: [
          IslamicHeader(
            title: 'قراءة القرآن الكريم',
            subtitle: 'برواية ورش عن نافع — ٤ أحزاب يومياً',
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
                slivers: [
                  // ─── Daily card ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildDailyCard(),
                    ),
                  ),
                  // ─── Hizb selector ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildHizbSelector(),
                    ),
                  ),
                  // ─── Warsh info + reading settings ───────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildWarshInfoBar(context),
                    ),
                  ),
                  // ─── Content ─────────────────────────────────────────
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  else if (_error != null)
                    SliverFillRemaining(child: _buildError())
                  else
                    _buildVerseSliver(),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily suggestion card ─────────────────────────────────────────────────
  Widget _buildDailyCard() {
    final endHizb = (_wirdStartHizb + dailyHizbs - 2) % totalHizbs + 1;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 36),
              Text(
                'وردك اليوم',
                style: AppTheme.arabicTitle(size: 18, color: Colors.white),
              ),
              GestureDetector(
                onTap: _showPickWirdStart,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الحزب $_wirdStartHizb إلى الحزب $endHizb',
            style: AppTheme.arabicBody(size: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dailyHizbs, (i) {
              final hizb = (_wirdStartHizb + i - 1) % totalHizbs + 1;
              final isActive = hizb == _currentHizb;
              return GestureDetector(
                onTap: () => _selectHizb(hizb),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.gold
                          : AppTheme.gold.withValues(alpha: 0.4),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    'ح $hizb',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Hizb selector ─────────────────────────────────────────────────────────
  Widget _buildHizbSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الحزب',
          style: AppTheme.arabicTitle(size: 17, color: AppTheme.primaryGreen),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: totalHizbs,
            itemBuilder: (context, index) {
              final hizb = index + 1;
              final isSelected = hizb == _currentHizb;
              return GestureDetector(
                onTap: () => _selectHizb(hizb),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  width: 44,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$hizb',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.darkBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Warsh info + reading settings button ─────────────────────────────────
  Widget _buildWarshInfoBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.lightGold.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: AppTheme.gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'رواية ورش عن نافع — طريق الأزرق',
                  style: AppTheme.arabicBody(
                      size: 14, color: AppTheme.darkBrown),
                ),
              ),
              IconButton(
                tooltip: 'إعدادات القراءة',
                icon: const Icon(Icons.text_fields_rounded,
                    color: AppTheme.primaryGreen, size: 22),
                onPressed: () => _showReadingSettings(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 13,
                  color: AppTheme.darkBrown.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'الترقيم المعروض وفق العد المدني — مصحف مجمع الملك فهد',
                  style: AppTheme.arabicBody(
                    size: 11,
                    color: AppTheme.darkBrown.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Error widget ──────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              Icon(Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTheme.arabicBody(
                size: 15,
                color: AppTheme.darkBrown.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                'إعادة المحاولة',
                style: AppTheme.arabicBody(
                    size: 15, color: Colors.white),
              ),
              onPressed: () {
                setState(() => _error = null);
                _loadHizb(_currentHizb);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Verse sliver ──────────────────────────────────────────────────────────
  Widget _buildVerseSliver() {
    final verses = _cache[_currentHizb];
    if (verses == null || verses.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'لا توجد آيات',
              style: AppTheme.arabicBody(size: 15),
            ),
          ),
        ),
      );
    }

    // Group verses by surah
    final groups = <_SurahGroup>[];
    int? currentSurah;
    for (final v in verses) {
      if (v.surahNumber != currentSurah) {
        groups.add(_SurahGroup(surahNumber: v.surahNumber, verses: []));
        currentSurah = v.surahNumber;
      }
      groups.last.verses.add(v);
    }

    // Each group → one header + one continuous text block
    final items = <_SurahGroup>[];
    items.addAll(groups);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final g = items[index];
          final showBasmala = g.verses.first.verseNumber == 1 &&
              QuranService.hasSeparateBasmala(g.surahNumber);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SurahHeaderTile(surahNumber: g.surahNumber),
              _SurahTextBlock(
                surahNumber: g.surahNumber,
                verses: g.verses,
                showBasmala: showBasmala,
              ),
            ],
          );
        },
        childCount: items.length,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Internal data structures
// ──────────────────────────────────────────────────────────────────────────
class _SurahGroup {
  final int surahNumber;
  final List<QuranVerse> verses;
  _SurahGroup({required this.surahNumber, required this.verses});
}

// ──────────────────────────────────────────────────────────────────────────
// Widget : en-tête de la sourate
// ──────────────────────────────────────────────────────────────────────────
class _SurahHeaderTile extends StatelessWidget {
  final int surahNumber;
  const _SurahHeaderTile({required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen,
              AppTheme.primaryGreen.withValues(alpha: 0.75),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$surahNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              'سورة ${QuranService.surahName(surahNumber)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Scheherazade New',
              ),
            ),
            const Icon(Icons.star_outline, color: AppTheme.gold, size: 20),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Widget : bloc de texte continu d'une sourate (style mushaf)
// ──────────────────────────────────────────────────────────────────────────
class _SurahTextBlock extends StatelessWidget {
  final int surahNumber;
  final List<QuranVerse> verses;
  final bool showBasmala;

  const _SurahTextBlock({
    required this.surahNumber,
    required this.verses,
    required this.showBasmala,
  });

  /// تحويل الرقم إلى أرقام عربية-هندية
  static String _toArabicNumeral(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  /// Supprime tout ce qui suit le texte de l'ayah :
  /// espaces, marques RTL/LTR, ۝ (U+06DD), chiffres arabo-indics (U+0660-U+06F9)
  static String _stripTrailingVerseMarker(String text) {
    int end = text.length;
    while (end > 0) {
      final c = text.codeUnitAt(end - 1);
      if (c == 0x0020 ||                    // espace
          c == 0x00A0 ||                    // espace insécable
          c == 0x200F ||                    // RTL mark
          c == 0x200E ||                    // LTR mark
          c == 0x200C ||                    // ZWNJ
          c == 0x200D ||                    // ZWJ
          c == 0x06DD ||                    // ۝ End of Ayah (U+06DD)
          (c >= 0x0660 && c <= 0x0669) ||  // chiffres arabo-indics ٠-٩
          (c >= 0x06F0 && c <= 0x06F9)) {  // chiffres perso-arabes ۰-۹
        end--;
      } else {
        break;
      }
    }
    return text.substring(0, end);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingSettingsProvider>(
      builder: (context, settings, _) {
        // البسملة كسطر مستقل بتنسيق ذهبي
        final List<InlineSpan> spans = [];

        if (showBasmala) {
          spans.add(
            TextSpan(
              text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n',
              style: settings.readingStyle().copyWith(
                color: AppTheme.darkBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        // نص الآيات متدفق مع رقم الآية
        for (final v in verses) {
          final rawText = settings.processText(v.text);
          final text = _stripTrailingVerseMarker(rawText);
          final marker = ' ${_toArabicNumeral(v.verseNumber)} ';
          spans.add(TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'WarshKFGQPC',
              fontSize: settings.fontSize,
              color: AppTheme.darkBrown,
              height: 2.5,
            ),
          ));
          spans.add(
            TextSpan(
              text: marker,
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: (settings.fontSize * 0.8).clamp(11.0, 22.0),
                fontWeight: FontWeight.bold,
                height: 2.5,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.borderGold.withValues(alpha: 0.2),
              ),
            ),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'WarshKFGQPC',
                  height: 2.5,
                ),
                children: spans,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Bottom sheet : إعدادات القراءة
// ──────────────────────────────────────────────────────────────────────────
class _ReadingSettingsSheet extends StatelessWidget {
  const _ReadingSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Consumer<ReadingSettingsProvider>(
        builder: (context, settings, _) => Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'إعدادات القراءة',
                style: AppTheme.arabicTitle(
                    size: 18, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 20),

              // Font size
              Text('حجم الخط',
                  style: AppTheme.arabicBody(
                      size: 14, color: AppTheme.darkBrown)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppTheme.primaryGreen),
                    onPressed: settings.fontSize > 14
                        ? () => settings.setFontSize(settings.fontSize - 1)
                        : null,
                  ),
                  Expanded(
                    child: Slider(
                      min: 14,
                      max: 32,
                      divisions: 18,
                      value: settings.fontSize,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: settings.setFontSize,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppTheme.primaryGreen),
                    onPressed: settings.fontSize < 32
                        ? () => settings.setFontSize(settings.fontSize + 1)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Font choice
              Text('نوع الخط',
                  style: AppTheme.arabicBody(
                      size: 14, color: AppTheme.darkBrown)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ArabicFont.values.map((f) {
                  final isSelected = settings.font == f;
                  return ChoiceChip(
                    label: Text(
                      f.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primaryGreen,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryGreen,
                    backgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.08),
                    side: BorderSide(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                    onSelected: (_) => settings.setFont(f),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Tashkeel toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إظهار التشكيل',
                      style: AppTheme.arabicBody(
                          size: 14, color: AppTheme.darkBrown)),
                  Switch(
                    value: settings.showTachkil,
                    activeThumbColor: AppTheme.primaryGreen,
                    onChanged: settings.setTachkil,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Bottom sheet : اختيار نقطة بداية الورد
// ──────────────────────────────────────────────────────────────────────────
class _WirdStartPickerSheet extends StatefulWidget {
  final int currentStart;
  final int totalHizbs;
  final ValueChanged<int> onSelected;

  const _WirdStartPickerSheet({
    required this.currentStart,
    required this.totalHizbs,
    required this.onSelected,
  });

  @override
  State<_WirdStartPickerSheet> createState() => _WirdStartPickerSheetState();
}

class _WirdStartPickerSheetState extends State<_WirdStartPickerSheet> {
  late int _selected;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentStart;
    // تمرير القائمة إلى الحزب المحدد
    final offset = ((widget.currentStart - 1) ~/ 5) * 52.0;
    _scrollController = ScrollController(initialScrollOffset: offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.play_circle_outline,
                    color: AppTheme.primaryGreen, size: 22),
                const SizedBox(width: 8),
                Text(
                  'اختر حزب البداية',
                  style: AppTheme.arabicTitle(
                      size: 17, color: AppTheme.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'سيبدأ وردك من هذا الحزب وينتهي بعد ٤ أحزاب',
              style: AppTheme.arabicBody(
                  size: 13, color: AppTheme.darkBrown.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemCount: widget.totalHizbs,
                itemBuilder: (context, index) {
                  final hizb = index + 1;
                  final isSelected = hizb == _selected;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = hizb),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : AppTheme.cream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$hizb',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.darkBrown,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => widget.onSelected(_selected),
                child: Text(
                  'تأكيد — ابدأ من الحزب $_selected',
                  style: AppTheme.arabicBody(size: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

