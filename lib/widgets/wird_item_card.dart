import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/wird_model.dart';

class WirdItemCard extends StatefulWidget {
  final WirdItem item;
  final int index;

  const WirdItemCard({super.key, required this.item, required this.index});

  @override
  State<WirdItemCard> createState() => _WirdItemCardState();
}

class _WirdItemCardState extends State<WirdItemCard> {
  int _currentCount = 0;

  @override
  Widget build(BuildContext context) {
    final target = widget.item.repetitions;
    final isCompleted = _currentCount >= target;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.lightGold.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? AppTheme.gold : AppTheme.borderGold.withValues(alpha: 0.3),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.gold.withValues(alpha: 0.2)
                    : AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.gold : AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${widget.index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: AppTheme.arabicTitle(size: 17, color: AppTheme.primaryGreen),
                    ),
                  ),
                  if (target > 1)
                    _RepetitionBadge(
                      current: _currentCount,
                      target: target,
                    ),
                ],
              ),
            ),

            // Optional Istiada
            if (widget.item.hasIstiada)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
                  style: AppTheme.arabicBody(
                    size: 14,
                    color: AppTheme.primaryGreen.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Main text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.item.text,
                style: AppTheme.arabicVerse(size: 19),
                textAlign: TextAlign.center,
              ),
            ),

            // Instruction
            if (widget.item.instruction != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightGold.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '✦ ${widget.item.instruction!}',
                  style: AppTheme.arabicBody(size: 14, color: AppTheme.darkBrown),
                  textAlign: TextAlign.center,
                ),
              ),

            // Counter button
            if (target > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _CounterButton(
                  current: _currentCount,
                  target: target,
                  onTap: () {
                    setState(() {
                      if (_currentCount < target) {
                        _currentCount++;
                      } else {
                        _currentCount = 0;
                      }
                    });
                  },
                  onReset: () => setState(() => _currentCount = 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RepetitionBadge extends StatelessWidget {
  final int current;
  final int target;

  const _RepetitionBadge({required this.current, required this.target});

  @override
  Widget build(BuildContext context) {
    final done = current >= target;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: done ? AppTheme.gold : AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done ? AppTheme.gold : AppTheme.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        done ? '✓ $target×' : '$current/$target×',
        style: TextStyle(
          color: done ? Colors.white : AppTheme.primaryGreen,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final int current;
  final int target;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const _CounterButton({
    required this.current,
    required this.target,
    required this.onTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final done = current >= target;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: done ? AppTheme.gold : AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  done ? 'مكتمل ✓' : 'عدّ ($current/$target)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (current > 0) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReset,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.refresh, color: Colors.grey, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}
