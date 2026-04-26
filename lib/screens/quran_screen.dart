import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_header.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  int _currentHizb = 1;
  // 4 أحزاب يومياً × 7 أيام = 28 حزب بالأسبوع (نصف القرآن تقريباً في الأسبوع)
  // القرآن الكريم: 60 حزباً = 30 جزءاً (حزبان لكل جزء)
  static const int totalHizbs = 60;
  static const int dailyHizbs = 4;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final suggestedStart = ((dayOfYear * dailyHizbs) % totalHizbs) + 1;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Column(
        children: [
          IslamicHeader(
            title: 'قراءة القرآن الكريم',
            subtitle: 'برواية ورش عن نافع — ٤ أحزاب يومياً',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Daily suggestion card
                    _buildDailyCard(suggestedStart),
                    const SizedBox(height: 20),
                    // Hizb selector
                    _buildHizbSelector(),
                    const SizedBox(height: 20),
                    // Warsh info
                    _buildWarshInfo(),
                    const SizedBox(height: 20),
                    // Content placeholder
                    _buildContentPlaceholder(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(int suggestedStart) {
    final end = suggestedStart + dailyHizbs - 1;
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
          Text(
            'وردك اليوم',
            style: AppTheme.arabicTitle(size: 18, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'الحزب $suggestedStart إلى الحزب ${end > totalHizbs ? end - totalHizbs : end}',
            style: AppTheme.arabicBody(size: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dailyHizbs, (i) {
              final hizb = ((suggestedStart + i - 1) % totalHizbs) + 1;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'ح $hizb',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

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
                onTap: () => setState(() => _currentHizb = hizb),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  width: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : Colors.white,
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
                        color: isSelected ? Colors.white : AppTheme.darkBrown,
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

  Widget _buildWarshInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightGold.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'رواية ورش عن نافع — طريقة الأزرق',
              style: AppTheme.arabicBody(size: 14, color: AppTheme.darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: AppTheme.gold.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'الحزب $_currentHizb',
            style: AppTheme.arabicTitle(size: 22, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة نص القرآن الكريم\nبرواية ورش قريباً بإذن الله',
            style: AppTheme.arabicBody(
              size: 15,
              color: AppTheme.darkBrown.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nوَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
              style: AppTheme.arabicVerse(size: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
