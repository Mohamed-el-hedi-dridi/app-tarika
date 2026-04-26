import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/wird_aam_data.dart';
import '../data/wird_yawmi_data.dart';
import '../widgets/wird_item_card.dart';
import '../widgets/islamic_header.dart';

class WirdAamScreen extends StatefulWidget {
  const WirdAamScreen({super.key});

  @override
  State<WirdAamScreen> createState() => _WirdAamScreenState();
}

class _WirdAamScreenState extends State<WirdAamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Auto-sélection matin/soir selon l'heure
    final hour = DateTime.now().hour;
    if (hour >= 16 || hour < 5) {
      _tabController.index = 1; // مساء
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Column(
        children: [
          IslamicHeader(
            title: 'الورد العام',
            subtitle: 'الوظيفة والورد',
            trailing: _buildTabBar(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSection('صباحاً', isMorning: true),
                _buildSection('مساءً', isMorning: false),
                _buildYawmiSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.gold,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 16),
                const SizedBox(width: 6),
                Text('صباحاً', style: AppTheme.arabicBody(size: 14, color: Colors.white)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nightlight_outlined, size: 16),
                const SizedBox(width: 6),
                Text('مساءً', style: AppTheme.arabicBody(size: 14, color: Colors.white)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.today_outlined, size: 16),
                const SizedBox(width: 6),
                Text('يومي', style: AppTheme.arabicBody(size: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String timeLabel, {required bool isMorning}) {
    final filteredWazifa = wazifaItems
        .where((item) => !isMorning || !item.eveningOnly)
        .toList();
    final filteredWird = wirdItems
        .where((item) => !isMorning || !item.eveningOnly)
        .toList();
    final allItems = [...filteredWazifa, ...filteredWird];

    if (allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isMorning ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                size: 80,
                color: AppTheme.gold.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                'الورد $timeLabel',
                style: AppTheme.arabicTitle(size: 20, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 12),
              Text(
                'سيتم إضافة محتوى الوظيفة والورد قريباً\nبإذن الله تعالى',
                style: AppTheme.arabicBody(
                  size: 16,
                  color: AppTheme.darkBrown.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // نبني قائمة مدمجة: وظيفة + فاصل + ورد
    final int wazifaCount = filteredWazifa.length;
    final int wirdCount = filteredWird.length;
    // إجمالي العناصر = وظيفة + (فاصل إن وجد ورد) + ورد
    final int totalCount = wazifaCount + (wirdCount > 0 ? 1 + wirdCount : 0);

    return ListView.builder(
      itemCount: totalCount,
      padding: const EdgeInsets.only(bottom: 32),
      itemBuilder: (context, index) {
        // عناصر الوظيفة
        if (index < wazifaCount) {
          return WirdItemCard(item: filteredWazifa[index], index: index);
        }
        // الفاصل بين الوظيفة والورد
        if (index == wazifaCount) {
          return _buildSectionDivider('ورد الطريقة');
        }
        // عناصر الورد
        final wirdIndex = index - wazifaCount - 1;
        return WirdItemCard(item: filteredWird[wirdIndex], index: wirdIndex);
      },
    );
  }

  Widget _buildYawmiSection() {
    return ListView.builder(
      itemCount: wirdYawmiItems.length,
      padding: const EdgeInsets.only(bottom: 32),
      itemBuilder: (context, index) =>
          WirdItemCard(item: wirdYawmiItems[index], index: index),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppTheme.borderGold],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: AppTheme.arabicTitle(size: 14, color: AppTheme.gold),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.borderGold, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
