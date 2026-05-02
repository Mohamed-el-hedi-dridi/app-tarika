import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/notification_service.dart';

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
                const SizedBox(height: 12),
                const _NotificationSettings(),
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
              'وِرْدُ الصَّبَاحِ بَعْدَ صَلَاةِ الصُّبْحِ',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildReminderRow(
              Icons.nightlight,
              'وِرْدُ المَسَاءِ بَعْدَ صَلَاةِ المَغْرِبِ',
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

  Future<void> _pickTime(BuildContext context, bool isMorning) async {
    if (_prefs == null) return;
    final initial = TimeOfDay(
      hour:   isMorning ? _prefs!.morningHour   : _prefs!.eveningHour,
      minute: isMorning ? _prefs!.morningMinute : _prefs!.eveningMinute,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final updated = isMorning
        ? NotificationPrefs(
            morningEnabled: _prefs!.morningEnabled,
            morningHour:    picked.hour,
            morningMinute:  picked.minute,
            eveningEnabled: _prefs!.eveningEnabled,
            eveningHour:    _prefs!.eveningHour,
            eveningMinute:  _prefs!.eveningMinute,
          )
        : NotificationPrefs(
            morningEnabled: _prefs!.morningEnabled,
            morningHour:    _prefs!.morningHour,
            morningMinute:  _prefs!.morningMinute,
            eveningEnabled: _prefs!.eveningEnabled,
            eveningHour:    picked.hour,
            eveningMinute:  picked.minute,
          );
    await NotificationService.instance.saveAndSchedule(updated);
    if (mounted) setState(() => _prefs = updated);
  }

  Future<void> _toggle(bool isMorning, bool value) async {
    if (_prefs == null) return;
    final updated = isMorning
        ? NotificationPrefs(
            morningEnabled: value,
            morningHour:    _prefs!.morningHour,
            morningMinute:  _prefs!.morningMinute,
            eveningEnabled: _prefs!.eveningEnabled,
            eveningHour:    _prefs!.eveningHour,
            eveningMinute:  _prefs!.eveningMinute,
          )
        : NotificationPrefs(
            morningEnabled: _prefs!.morningEnabled,
            morningHour:    _prefs!.morningHour,
            morningMinute:  _prefs!.morningMinute,
            eveningEnabled: value,
            eveningHour:    _prefs!.eveningHour,
            eveningMinute:  _prefs!.eveningMinute,
          );
    await NotificationService.instance.saveAndSchedule(updated);
    if (mounted) setState(() => _prefs = updated);
  }

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

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
                _NotifRow(
                  icon: Icons.wb_sunny,
                  label: 'ورد الصباح',
                  sublabel: 'بعد صلاة الصبح',
                  color: Colors.orange,
                  enabled: _prefs!.morningEnabled,
                  time: _fmt(_prefs!.morningHour, _prefs!.morningMinute),
                  onToggle: (v) => _toggle(true, v),
                  onTimeTap: () => _pickTime(context, true),
                ),
                const Divider(height: 16),
                _NotifRow(
                  icon: Icons.nightlight,
                  label: 'ورد المساء',
                  sublabel: 'بعد صلاة المغرب',
                  color: const Color(0xFF4A235A),
                  enabled: _prefs!.eveningEnabled,
                  time: _fmt(_prefs!.eveningHour, _prefs!.eveningMinute),
                  onToggle: (v) => _toggle(false, v),
                  onTimeTap: () => _pickTime(context, false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool enabled;
  final String time;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  const _NotifRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeTap,
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
                  style: AppTheme.arabicBody(
                      size: 14, color: AppTheme.darkBrown)),
              Text(sublabel,
                  style: AppTheme.arabicBody(
                      size: 12,
                      color: AppTheme.darkBrown.withValues(alpha: 0.5))),
            ],
          ),
        ),
        if (enabled)
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
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
