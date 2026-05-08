import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/dalail_data.dart';
import '../widgets/islamic_header.dart';
import '../providers/reading_settings_provider.dart';

class DalailScreen extends StatefulWidget {
  const DalailScreen({super.key});

  @override
  State<DalailScreen> createState() => _DalailScreenState();
}

class _DalailScreenState extends State<DalailScreen> {
  late DalailDay _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = _getToday(now.weekday);
  }

  DalailDay _getToday(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return DalailDay.saturday;
      case DateTime.sunday:
        return DalailDay.sunday;
      case DateTime.monday:
        return DalailDay.monday;
      case DateTime.tuesday:
        return DalailDay.tuesday;
      case DateTime.wednesday:
        return DalailDay.wednesday;
      case DateTime.thursday:
        return DalailDay.thursday;
      case DateTime.friday:
        return DalailDay.friday;
      default:
        return DalailDay.saturday;
    }
  }

  void _showReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReadingSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = dalailSchedule[_selectedDay]!;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
          IslamicHeader(
            title: 'دلائل الخيرات',
            subtitle: section.arabicName,
          ),
          // ── شريط اختيار اليوم + زر إعدادات القراءة ──
          Container(
            height: 56,
            color: AppTheme.primaryGreen.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    reverse: true,
                    children: DalailDay.values.map((day) {
                      final isSelected = day == _selectedDay;
                      final isToday = day.dayIndex == DateTime.now().weekday;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isToday
                                  ? AppTheme.gold
                                  : AppTheme.primaryGreen.withValues(
                                      alpha: 0.3,
                                    ),
                              width: isToday ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            day.shortName,
                            style: AppTheme.arabicBody(
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // ── زر إعدادات الخط والتشكيل ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    tooltip: 'إعدادات القراءة',
                    icon: const Icon(
                      Icons.text_fields_rounded,
                      color: AppTheme.primaryGreen,
                      size: 22,
                    ),
                    onPressed: () => _showReadingSettings(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent(section)),
        ],
        ),
      ),
    );
  }

  Widget _buildContent(DalailDaySection section) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),

          // ── دعاء البدء ──
          _DuaCard(
            label: 'دعاء النية',

            labelColor: AppTheme.primaryGreen,
            borderColor: AppTheme.primaryGreen,
            icon: Icons.play_circle_outline,
            text: dalailOpeningDua,
          ),

          const SizedBox(height: 16),

          // ── محتوى الحزب ──
          _HizbCard(section: section),

          const SizedBox(height: 16),

          // ── دعاء العقب ──
          _DuaCard(
            label: 'دعاء يُقرأ عَقِبَ دلائل الخيرات',
            labelColor: const Color(0xFF6A1B9A),
            borderColor: const Color(0xFF6A1B9A),
            icon: Icons.stop_circle_outlined,
            text: dalailClosingDua,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Widget : carte دعاء (بدء / عقب)
// ──────────────────────────────────────────
class _DuaCard extends StatefulWidget {
  final String label;
  final Color labelColor;
  final Color borderColor;
  final IconData icon;
  final String text;

  const _DuaCard({
    required this.label,
    required this.labelColor,
    required this.borderColor,
    required this.icon,
    required this.text,
  });

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.borderColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.borderColor.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header — tap to expand
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.labelColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(13),
                  bottom: _expanded ? Radius.zero : const Radius.circular(13),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.labelColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppTheme.arabicTitle(size: 15, color: widget.labelColor),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: widget.labelColor,
                  ),
                ],
              ),
            ),
          ),

          // Body
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Consumer<ReadingSettingsProvider>(
                builder: (context, settings, _) => Text(
                  settings.processText(widget.text),
                  style: settings.readingStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Widget : carte محتوى الحزب
// ──────────────────────────────────────────
class _HizbCard extends StatelessWidget {
  final DalailDaySection section;
  const _HizbCard({required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.content.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderGold.withValues(alpha: 0.3)),
        ),
        child: Consumer<ReadingSettingsProvider>(
          builder: (context, settings, _) => Text(
            settings.processText(section.content),
            style: settings.readingStyle(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Placeholder quand le contenu n'est pas encore ajouté
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 72,
            color: AppTheme.gold.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 16),
          Text(
            section.hizb,
            style: AppTheme.arabicTitle(size: 20, color: AppTheme.primaryGreen),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة نص الحزب قريباً\nبإذن الله تعالى',
            style: AppTheme.arabicBody(
              size: 15,
              color: AppTheme.darkBrown.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.lightGold.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ\nعَلَى سَيِّدِنَا مُحَمَّدٍ',
              style: AppTheme.arabicVerse(size: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

extension on DalailDaySection {
  String get arabicName => day.arabicName;
}

// ──────────────────────────────────────────
// Bottom Sheet : إعدادات القراءة (خط + تشكيل + حجم)
// ──────────────────────────────────────────
class _ReadingSettingsSheet extends StatelessWidget {
  const _ReadingSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingSettingsProvider>(
      builder: (context, settings, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Text(
                  'إعدادات القراءة',
                  style: AppTheme.arabicTitle(
                    size: 18,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),

                // ── الخط العربي الإسلامي ──
                _SectionLabel(
                  icon: Icons.font_download_outlined,
                  label: 'الخط العربي الإسلامي',
                ),
                const SizedBox(height: 10),
                Row(
                  children: ArabicFont.values.map((f) {
                    final selected = settings.font == f;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => settings.setFont(f),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryGreen
                                : AppTheme.cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryGreen
                                  : AppTheme.borderGold.withValues(alpha: 0.4),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            f.displayName,
                            style: AppTheme.arabicBody(
                              size: 12,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.darkBrown,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Preview text
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.parchment,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    settings.processText(
                      'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى سَيِّدِنَا مُحَمَّدٍ',
                    ),
                    style: settings.readingStyle(size: settings.fontSize),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // ── حجم الخط ──
                _SectionLabel(
                  icon: Icons.format_size,
                  label: 'حجم الخط',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          settings.setFontSize(settings.fontSize - 1),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        min: 14,
                        max: 30,
                        divisions: 16,
                        value: settings.fontSize,
                        activeColor: AppTheme.primaryGreen,                        thumbColor: AppTheme.primaryGreen,                        inactiveColor:
                            AppTheme.primaryGreen.withValues(alpha: 0.2),
                        onChanged: settings.setFontSize,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          settings.setFontSize(settings.fontSize + 1),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        settings.fontSize.round().toString(),
                        style: AppTheme.arabicBody(
                          size: 14,
                          color: AppTheme.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── التشكيل ──
                _SectionLabel(
                  icon: Icons.spellcheck,
                  label: 'التشكيل (الحركات)',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      settings.showTachkil
                          ? 'التشكيل مُفعَّل — النصّ بكامل الحركات'
                          : 'التشكيل مُعطَّل — نصّ بدون حركات',
                      style: AppTheme.arabicBody(
                        size: 13,
                        color: AppTheme.darkBrown.withValues(alpha: 0.7),
                      ),
                    ),
                    Switch(
                      value: settings.showTachkil,
                      onChanged: settings.setTachkil,
                      thumbColor: WidgetStatePropertyAll(
                        settings.showTachkil
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.gold),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTheme.arabicTitle(size: 14, color: AppTheme.darkBrown),
        ),
      ],
    );
  }
}
