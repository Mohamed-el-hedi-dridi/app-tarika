import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/wird_yawmi_data.dart';
import '../widgets/wird_item_card.dart';
import '../widgets/islamic_header.dart';

class WirdYawmiScreen extends StatelessWidget {
  const WirdYawmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'الورد اليومي',
              subtitle: 'يومياً بإذن الله',
              trailing: _buildBadge(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WirdItemCard(
                item: wirdYawmiItems[index],
                index: index,
              ),
              childCount: wirdYawmiItems.length,
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
        'الورد اليومي',
        style: AppTheme.arabicVerse(size: 15, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
