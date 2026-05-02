import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/wird_aam_data.dart';
import '../widgets/wird_item_card.dart';
import '../widgets/islamic_header.dart';
import '../providers/wird_completion_provider.dart';

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
          SliverToBoxAdapter(
            child: _WirdAamCompletionFooter(),
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

// ─────────────────────────────────────────────────────────────────────────────
// Pied de page : boutons de confirmation الورد العام
// ─────────────────────────────────────────────────────────────────────────────
class _WirdAamCompletionFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WirdCompletionProvider>();
    final allDone  = provider.isAamAllDone;
    const color    = Color(0xFF4A235A); // violet طريقة
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: allDone ? AppTheme.gold : AppTheme.borderGold.withValues(alpha: 0.3),
              width: allDone ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Titre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: allDone
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.07),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Row(
                  children: [
                    Icon(
                      allDone ? Icons.check_circle : Icons.checklist_rtl,
                      color: allDone ? AppTheme.gold : color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      allDone
                          ? 'تم الورد العام — بارك الله فيك'
                          : 'تأكيد إتمام الورد العام',
                      style: AppTheme.arabicTitle(
                        size: 15,
                        color: allDone ? AppTheme.borderGold : color,
                      ),
                    ),
                  ],
                ),
              ),
              // Boutons صباح / مساء
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _AamButton(
                        label: 'ورد الصباح',
                        sublabel: 'بعد صلاة الفجر',
                        icon: Icons.wb_sunny,
                        color: Colors.orange.shade700,
                        isDone: provider.isAamSobe7Done,
                        onToggle: () =>
                            provider.setAamSobe7Done(!provider.isAamSobe7Done),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AamButton(
                        label: 'ورد المساء',
                        sublabel: 'بعد صلاة المغرب',
                        icon: Icons.nightlight_round,
                        color: color,
                        isDone: provider.isAamMasa2Done,
                        onToggle: () =>
                            provider.setAamMasa2Done(!provider.isAamMasa2Done),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AamButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final bool isDone;
  final VoidCallback onToggle;

  const _AamButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.isDone,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone ? color : Colors.grey.shade300,
            width: isDone ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isDone ? Icons.check_circle : icon,
              color: isDone ? color : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.arabicTitle(
                size: 14,
                color: isDone ? color : AppTheme.darkBrown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: AppTheme.arabicBody(
                size: 11,
                color: isDone
                    ? color.withValues(alpha: 0.8)
                    : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
