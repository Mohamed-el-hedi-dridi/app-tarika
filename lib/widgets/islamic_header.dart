import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IslamicHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const IslamicHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _OrnamentLine(),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.arabicTitle(size: 22, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 12),
                const _OrnamentLine(),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppTheme.arabicBody(
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(height: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _OrnamentLine extends StatelessWidget {
  const _OrnamentLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 30, height: 1, color: AppTheme.gold),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.gold,
            shape: BoxShape.circle,
          ),
        ),
        Container(width: 10, height: 1, color: AppTheme.gold),
      ],
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
