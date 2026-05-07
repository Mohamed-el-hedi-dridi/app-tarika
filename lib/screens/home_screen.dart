import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/notification_service.dart';
import '../widgets/prayer_times_card.dart';
import '../providers/wird_completion_provider.dart';

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
                const PrayerTimesCard(),
                const SizedBox(height: 12),
                _buildDailyProgress(context),
                const SizedBox(height: 12),
                const _NotificationSettings(),
                const SizedBox(height: 16),
                const _AppVersionInfo(),
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

    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hero_mosque.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.45),
                  AppTheme.primaryGreen.withValues(alpha: 0.65),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
        title: 'الوظيفة',
        subtitle: 'يُقرأ صباحاً ومساءً',
        icon: Icons.book_outlined,
        color: const Color(0xFF4A148C),
        tabIndex: 2,
      ),
      _MenuItem(
        title: 'الورد العام',
        subtitle: 'ورد الطريقة',
        icon: Icons.menu_book,
        color: const Color(0xFF4A235A),
        tabIndex: 3,
      ),
      _MenuItem(
        title: 'الورد اليومي',
        subtitle: 'يومياً بإذن الله',
        icon: Icons.today_outlined,
        color: const Color(0xFF006064),
        tabIndex: 4,
      ),
      _MenuItem(
        title: 'ورد التحصين',
        subtitle: 'قبل الخروج',
        icon: Icons.shield_outlined,
        color: const Color(0xFF7B3F00),
        tabIndex: 5,
      ),
      _MenuItem(
        title: 'القرآن الكريم',
        subtitle: '٤ أحزاب — رواية ورش',
        icon: Icons.mosque_outlined,
        color: const Color(0xFF0D47A1),
        tabIndex: 6,
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

  Widget _buildDailyProgress(BuildContext context) {
    final cp = context.watch<WirdCompletionProvider>();
    final allWirdDone = cp.isAllDone && cp.isAamAllDone;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Bannière "Tout terminé" ───────────────────────────────────────
          if (allWirdDone) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.85),
                    AppTheme.lightGreen.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.gold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'أُتِمَّ الوِرْدُ — بارك الله فيك',
                    style: AppTheme.arabicTitle(size: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          // ── Rappels avec état de complétion ──────────────────────────────
          Container(
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
                // ── الورد العام ───────────────────────────────────────────
                _buildSectionLabel('الورد العام'),
                const SizedBox(height: 6),
                _buildReminderRow(
                  Icons.wb_sunny,
                  'الوِرْدُ العَامُ بَعْدَ صَلَاةِ الصُّبْحِ',
                  Colors.orange,
                  isDone: cp.isAamSobe7Done,
                ),
                const SizedBox(height: 8),
                _buildReminderRow(
                  Icons.nightlight,
                  'الوِرْدُ العَامُ بَعْدَ صَلَاةِ المَغْرِبِ',
                  const Color(0xFF4A235A),
                  isDone: cp.isAamMasa2Done,
                ),
                const SizedBox(height: 12),
                // ── تحصين ─────────────────────────────────────────────────
                _buildReminderRow(
                  Icons.home_outlined,
                  'التَّحْصِينُ عِنْدَ الخُرُوجِ مِنَ المَنْزِلِ',
                  const Color(0xFF7B3F00),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderGold.withValues(alpha: 0.3))),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTheme.arabicBody(
            size: 12,
            color: AppTheme.primaryGreen.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: AppTheme.borderGold.withValues(alpha: 0.3))),
      ],
    );
  }

  Widget _buildReminderRow(IconData icon, String text, Color color,
      {bool isDone = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDone ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDone ? Icons.check : icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTheme.arabicBody(
              size: 14,
              color: isDone
                  ? AppTheme.darkBrown.withValues(alpha: 0.5)
                  : AppTheme.darkBrown,
            ),
          ),
        ),
        if (isDone)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              'تم',
              style: AppTheme.arabicBody(size: 12, color: color),
            ),
          ),
      ],
    );
  }
}

class _AppVersionInfo extends StatefulWidget {
  const _AppVersionInfo();

  @override
  State<_AppVersionInfo> createState() => _AppVersionInfoState();
}

class _AppVersionInfoState extends State<_AppVersionInfo> {
  late final Future<PackageInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _infoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'الإصدار ${info.version} (Build ${info.buildNumber})',
            style: AppTheme.arabicBody(
              size: 12,
              color: AppTheme.darkBrown.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
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

// ─────────────────────────────────────────────────────────────────────────────
// Widget : paramètres de notifications
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationSettings extends StatefulWidget {
  const _NotificationSettings();

  @override
  State<_NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<_NotificationSettings> {
  NotificationPrefs? _prefs;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.loadPrefs().then((p) {
      if (mounted) setState(() => _prefs = p);
    });
  }

  Future<void> _togglePrayer(String key, bool value) async {
    if (_prefs == null) return;
    final updated = NotificationPrefs(
      morningEnabled: _prefs!.morningEnabled,
      morningHour:    _prefs!.morningHour,
      morningMinute:  _prefs!.morningMinute,
      eveningEnabled: _prefs!.eveningEnabled,
      eveningHour:    _prefs!.eveningHour,
      eveningMinute:  _prefs!.eveningMinute,
      duhaEnabled:        key == 'duha'        ? value : _prefs!.duhaEnabled,
      fajrWirdEnabled:    key == 'fajrWird'    ? value : _prefs!.fajrWirdEnabled,
      maghribWirdEnabled: key == 'maghribWird' ? value : _prefs!.maghribWirdEnabled,
      kahfEnabled:        key == 'kahf'        ? value : _prefs!.kahfEnabled,
      kahfHour:   _prefs!.kahfHour,
      kahfMinute: _prefs!.kahfMinute,
    );
    await NotificationService.instance.saveAndSchedulePrayerAlarms(updated);
    if (mounted) setState(() => _prefs = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
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
              Row(
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'تنبيهات الأوراد',
                    style: AppTheme.arabicTitle(
                        size: 16, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_prefs == null)
                const Center(child: CircularProgressIndicator())
              else ...[                
                _NotifSimpleRow(
                  icon: Icons.brightness_3,
                  label: 'ورد الصباح',
                  sublabel: 'بعد الفجر بـ ٣٠ دقيقة',
                  color: Colors.indigo,
                  enabled: _prefs!.fajrWirdEnabled,
                  onToggle: (v) => _togglePrayer('fajrWird', v),
                ),
                const SizedBox(height: 6),
                _NotifSimpleRow(
                  icon: Icons.wb_sunny_outlined,
                  label: 'صلاة الضحى',
                  sublabel: 'بعد الشروق بـ ٢٠ دقيقة',
                  color: Colors.amber.shade700,
                  enabled: _prefs!.duhaEnabled,
                  onToggle: (v) => _togglePrayer('duha', v),
                ),
                const SizedBox(height: 6),
                _NotifSimpleRow(
                  icon: Icons.nightlight_round,
                  label: 'ورد المساء',
                  sublabel: 'بعد المغرب بـ ٢٠ دقيقة',
                  color: const Color(0xFF4A235A),
                  enabled: _prefs!.maghribWirdEnabled,
                  onToggle: (v) => _togglePrayer('maghribWird', v),
                ),
                const SizedBox(height: 6),
                _NotifSimpleRow(
                  icon: Icons.menu_book_rounded,
                  label: 'سورة الكهف',
                  sublabel: 'كل يوم جمعة في الساعة ٨:٠٠',
                  color: AppTheme.primaryGreen,
                  enabled: _prefs!.kahfEnabled,
                  onToggle: (v) => _togglePrayer('kahf', v),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifSimpleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _NotifSimpleRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTheme.arabicBody(size: 14, color: AppTheme.darkBrown)),
              Text(sublabel,
                  style: AppTheme.arabicBody(
                      size: 12,
                      color: AppTheme.darkBrown.withValues(alpha: 0.5))),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: onToggle,
          activeThumbColor: Colors.white,
          activeTrackColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }
}
