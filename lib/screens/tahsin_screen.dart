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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'ورد التحصين',
              subtitle: 'قبل الخروج من المنزل',
              trailing: _buildBismillah(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WirdItemCard(
                item: tahsinItems[index],
                index: index,
              ),
              childCount: tahsinItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
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
