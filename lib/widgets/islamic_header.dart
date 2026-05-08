import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IslamicHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  const IslamicHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_mosque.png',
              fit: BoxFit.cover,
            ),
          ),
          // Bouton retour uniquement
          if (showBack)
            Positioned(
              top: topPadding + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentPlaceholder extends StatelessWidget {
  final String message;
  final IconData icon;

  const ContentPlaceholder({
    super.key,
    required this.message,
    this.icon = Icons.hourglass_empty,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.gold.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              message,
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
}
