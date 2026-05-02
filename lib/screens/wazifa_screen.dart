import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/wird_aam_data.dart';
import '../widgets/wird_item_card.dart';
import '../widgets/islamic_header.dart';
import '../providers/wird_completion_provider.dart';

class WazifaScreen extends StatelessWidget {
  const WazifaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'الوظيفة',
              subtitle: 'يُقرأ صباحاً ومساءً',
              trailing: _buildBadge(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WirdItemCard(
                item: wazifaItems[index],
                index: index,
              ),
              childCount: wazifaItems.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _WirdCompletionFooter(),
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
        'الوظيفة الصباحية والمسائية',
        style: AppTheme.arabicVerse(size: 15, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pied de page : boutons de confirmation de complétion
// ─────────────────────────────────────────────────────────────────────────────
class _WirdCompletionFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WirdCompletionProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: provider.isAllDone
                  ? AppTheme.gold
                  : AppTheme.borderGold.withValues(alpha: 0.3),
              width: provider.isAllDone ? 2 : 1,
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
                  color: provider.isAllDone
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : AppTheme.primaryGreen.withValues(alpha: 0.07),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Row(
                  children: [
                    Icon(
                      provider.isAllDone
                          ? Icons.check_circle
                          : Icons.checklist_rtl,
                      color: provider.isAllDone
                          ? AppTheme.gold
                          : AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isAllDone
                          ? 'تم الورد — بارك الله فيك'
                          : 'تأكيد إتمام الورد',
                      style: AppTheme.arabicTitle(
                        size: 15,
                        color: provider.isAllDone
                            ? AppTheme.borderGold
                            : AppTheme.primaryGreen,
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
                      child: _CompletionButton(
                        label: 'ورد الصباح',
                        sublabel: 'بعد الفجر — بدون سورة الملك',
                        icon: Icons.wb_sunny,
                        color: Colors.orange.shade700,
                        isDone: provider.isSobe7Done,
                        onToggle: () => provider.setSobe7Done(!provider.isSobe7Done),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CompletionButton(
                        label: 'ورد المساء',
                        sublabel: 'بعد المغرب — مع سورة الملك',
                        icon: Icons.nightlight_round,
                        color: const Color(0xFF4A235A),
                        isDone: provider.isMasa2Done,
                        onToggle: () => provider.setMasa2Done(!provider.isMasa2Done),
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

class _CompletionButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final bool isDone;
  final VoidCallback onToggle;

  const _CompletionButton({
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
                color: isDone ? color.withValues(alpha: 0.8) : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
