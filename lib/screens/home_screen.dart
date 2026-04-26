import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(context),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'الأوراد اليومية',
                    style: AppTheme.arabicTitle(size: 20, color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMenuGrid(context),
                const SizedBox(height: 24),
                _buildDailyProgress(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'صباح الخير'
        : hour < 17
            ? 'مساء الخير'
            : 'مساء النور';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: AppTheme.gold),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: AppTheme.gold, size: 16),
              const SizedBox(width: 8),
              Container(width: 40, height: 1, color: AppTheme.gold),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'الطريقة الصوفية',
            style: AppTheme.arabicTitle(size: 26, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'أوراد وأذكار يومية',
            style: AppTheme.arabicBody(size: 15, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              greeting,
              style: AppTheme.arabicBody(size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final items = [
      _MenuItem(
        title: 'دلائل الخيرات',
        subtitle: 'مفهرس بالأيام',
        icon: Icons.auto_stories,
        color: const Color(0xFF1B5E20),
        tabIndex: 1,
      ),
      _MenuItem(
        title: 'الورد العام',
        subtitle: 'الوظيفة والورد',
        icon: Icons.menu_book,
        color: const Color(0xFF4A235A),
        tabIndex: 2,
      ),
      _MenuItem(
        title: 'ورد التحصين',
        subtitle: 'قبل الخروج',
        icon: Icons.shield_outlined,
        color: const Color(0xFF7B3F00),
        tabIndex: 3,
      ),
      _MenuItem(
        title: 'القرآن الكريم',
        subtitle: '٤ أحزاب — رواية ورش',
        icon: Icons.mosque_outlined,
        color: const Color(0xFF0D47A1),
        tabIndex: 4,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _MenuCard(item: items[index]),
    );
  }

  Widget _buildDailyProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تذكير',
              style: AppTheme.arabicTitle(size: 16, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 10),
            _buildReminderRow(
              Icons.wb_sunny,
              'وِرْدُ الصَّبَاحِ بَعْدَ صَلَاةِ الفَجْرِ',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildReminderRow(
              Icons.nightlight,
              'وِرْدُ المَسَاءِ بَعْدَ صَلَاةِ العَصْرِ',
              const Color(0xFF4A235A),
            ),
            const SizedBox(height: 8),
            _buildReminderRow(
              Icons.home_outlined,
              'التَّحْصِينُ عِنْدَ الخُرُوجِ مِنَ المَنْزِلِ',
              const Color(0xFF7B3F00),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTheme.arabicBody(size: 14, color: AppTheme.darkBrown),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int tabIndex;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tabIndex,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nav = context.findAncestorStateOfType<MainNavState>();
        nav?.setTab(item.tabIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: AppTheme.arabicTitle(size: 15, color: item.color),
              textAlign: TextAlign.center,
            ),
            Text(
              item.subtitle,
              style: AppTheme.arabicBody(
                size: 12,
                color: item.color.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


