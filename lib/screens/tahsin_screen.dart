import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/tahsin_data.dart';
import '../widgets/wird_item_card.dart';
import '../widgets/islamic_header.dart';

class TahsinScreen extends StatelessWidget {
  const TahsinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'ورد التحصين',
              subtitle: 'قبل الخروج من المنزل',
              trailing: _buildBismillah(),
            ),
          ),

          // ── القسم الأول : ورد التحصين قبل الخروج ────────────────────
          _buildSectionHeader('ورد التحصين قبل الخروج'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WirdItemCard(
                item: tahsinItems[index],
                index: index,
              ),
              childCount: tahsinItems.length,
            ),
          ),

          // ── القسم الثاني : ذكر التحصين ─────────────────────────────
          _buildSectionHeader('ذكر التحصين'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WirdItemCard(
                item: tahsinRuqyaItems[index],
                index: index,
              ),
              childCount: tahsinRuqyaItems.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTheme.arabicTitle(size: 16, color: AppTheme.darkBrown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBismillah() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: AppTheme.arabicVerse(size: 16, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
