import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/wird_aam_data.dart';
import '../widgets/wird_item_card.dart';
import '../widgets/islamic_header.dart';

class WirdAamScreen extends StatelessWidget {
  const WirdAamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'الورد العام',
              subtitle: 'ورد الطريقة الشاذلية',
              trailing: _buildBadge(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WirdItemCard(
                item: wirdItems[index],
                index: index,
              ),
              childCount: wirdItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'ورد الطريقة',
        style: AppTheme.arabicVerse(size: 15, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
