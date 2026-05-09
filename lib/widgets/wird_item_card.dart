import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/wird_model.dart';
import '../services/sound_service.dart';
import '../services/prayer_times_service.dart';

class WirdItemCard extends StatefulWidget {
  final WirdItem item;
  final int index;
  /// Identifiant de la liste : utilisé pour cloisonner la persistance.
  /// Suffixe `_m` = session Maghrib (masa2), sinon session Fajr (sobh).
  /// Exemples : 'yawmi', 'wazifa_s', 'wazifa_m', 'aam_s', 'aam_m', 'tahsin', 'ruqya'.
  final String listId;

  const WirdItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.listId,
  });

  @override
  State<WirdItemCard> createState() => _WirdItemCardState();
}

class _WirdItemCardState extends State<WirdItemCard>
    with SingleTickerProviderStateMixin {
  int  _currentCount = 0;
  bool _manualDone   = false; // سبحة يدوية
  String? _periodKey; // clé de période pour la persistance

  late AnimationController _tickController;
  late Animation<double>   _tickScale;
  late Animation<double>   _tickOpacity;

  @override
  void initState() {
    super.initState();
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _tickScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
    ]).animate(_tickController);
    _tickOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 35,
      ),
    ]).animate(_tickController);
    _tickController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _tickController.reset();
      }
    });
    // Charger l'état persisté après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProgress());
  }

  // ── Persistance ──────────────────────────────────────────────────────────

  /// Calcule la clé de période (YYYY-MM-DD) selon le type de session.
  /// Suffixe `_m`  → reset à Maghrib  |  sinon → reset à Fajr
  Future<String> _computePeriodKey() async {
    try {
      final times = await PrayerTimesService.instance.getToday();
      final now   = DateTime.now();
      final isEvening = widget.listId.endsWith('_m');
      final ref   = isEvening ? times.maghrib : times.fajr;
      final d     = now.isAfter(ref) ? now : now.subtract(const Duration(days: 1));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      final d = DateTime.now();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  String _prefsCountKey(String period) =>
      'dp_${widget.listId}_${period}_${widget.index}_c';
  String _prefsDoneKey(String period) =>
      'dp_${widget.listId}_${period}_${widget.index}_d';

  Future<void> _loadProgress() async {
    final period = await _computePeriodKey();
    final prefs  = await SharedPreferences.getInstance();
    final count  = prefs.getInt(_prefsCountKey(period))  ?? 0;
    final done   = prefs.getBool(_prefsDoneKey(period)) ?? false;
    if (!mounted) return;
    _periodKey = period;
    if (count != _currentCount || done != _manualDone) {
      setState(() {
        _currentCount = count;
        _manualDone   = done;
      });
    }
  }

  Future<void> _saveProgress() async {
    final period = _periodKey;
    if (period == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsCountKey(period),  _currentCount);
    await prefs.setBool(_prefsDoneKey(period), _manualDone);
  }

  @override
  void dispose() {
    _tickController.dispose();
    super.dispose();
  }

  void _triggerCompletion() {
    HapticFeedback.heavyImpact();
    SoundService.playDone();
    _tickController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final target      = widget.item.repetitions;
    final isCompleted = _manualDone || _currentCount >= target;

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
      child: Stack(
        children: [
          Directionality(
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
                      manualDone: _manualDone,
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

            // ─── Section Aya (optionnelle) ────────────────────────────────
            if (widget.item.ayaText != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _buildAyaRichText(widget.item.ayaText!),
              ),
              if (widget.item.ayaInstruction != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGold.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '✦ ${widget.item.ayaInstruction!}',
                    style: AppTheme.arabicBody(size: 14, color: AppTheme.darkBrown),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Divider(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  thickness: 1,
                ),
              ),
            ],

            // Main text (dhikr ou verset coranique)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                widget.item.ayaText != null ? 0 : 16,
                16,
                16,
              ),
              child: widget.item.isQuranVerse && widget.item.startVerseNumber != null
                  ? _buildQuranRichText(widget.item.text, widget.item.startVerseNumber!)
                  : Text(
                      widget.item.text,
                      style: widget.item.isQuranVerse
                          ? AppTheme.warshVerse(size: 19)
                          : AppTheme.arabicVerse(size: 19),
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

            // Counter button (repetitions > 1) or simple read toggle (repetitions == 1)
            if (target > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _CounterButton(
                      current: _currentCount,
                      target: target,
                      manualDone: _manualDone,
                      onTap: () {
                        if (_manualDone) return; // déjà terminé manuellement
                        setState(() {
                          if (_currentCount < target) {
                            _currentCount++;
                            if (_currentCount >= target) {
                              _triggerCompletion();
                            } else {
                              HapticFeedback.lightImpact();
                              SoundService.playClick();
                            }
                          } else {
                            _currentCount = 0;
                          }
                        });
                        _saveProgress();
                      },
                      onReset: () {
                        setState(() {
                          _currentCount = 0;
                          _manualDone   = false;
                        });
                        _saveProgress();
                      },
                    ),
                    // ── Ligne سبحة يدوية ──────────────────────────────
                    if (!_manualDone && _currentCount < target) ...[        
                      const SizedBox(height: 6),
                      _TasbihaButton(
                        onTap: () {
                          _triggerCompletion();
                          setState(() => _manualDone = true);
                          _saveProgress();
                        },
                      ),
                    ],
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _ReadToggleButton(
                  isDone: isCompleted,
                  onToggle: () {
                    setState(() => _currentCount = isCompleted ? 0 : 1);
                    _saveProgress();
                  },
                ),
              ),
          ],
        ),
      ),
      // ── Overlay animation tick ──────────────────────────────────────────
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _tickController,
            builder: (context, _) {
              if (_tickController.value == 0) return const SizedBox.shrink();
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(
                      alpha: 0.10 * _tickOpacity.value),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Opacity(
                    opacity: _tickOpacity.value,
                    child: Transform.scale(
                      scale: _tickScale.value,
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.gold,
                        size: 84,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ],
  ),
);
  }

  /// Affiche un texte coranique en parsant les ۝ pour numéroter les versets en vert.
  Widget _buildQuranRichText(String text, int startVerseNumber) {
    final parts = text.split(RegExp(r'۝[٠-٩]*'));
    if (parts.length <= 1) {
      return Text(
        text,
        style: AppTheme.warshVerse(size: 19),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      );
    }
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i],
          style: AppTheme.warshVerse(size: 19),
        ));
      }
      if (i < parts.length - 1) {
        spans.add(_verseCircleSpan(startVerseNumber + i));
      }
    }
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontFamily: 'WarshKFGQPC'),
        children: spans,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
  }

  static String _toArabicNumeral(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  /// Chiffre arabo-indic en vert : WarshKFGQPC dessine l'ornement autour automatiquement.
  static TextSpan _verseCircleSpan(int verseNumber) {
    return TextSpan(
      text: ' ${_toArabicNumeral(verseNumber)} ',
      style: TextStyle(
        color: AppTheme.primaryGreen,
        fontSize: 19,
        fontWeight: FontWeight.bold,
        height: 2.2,
      ),
    );
  }

  /// Affiche l'ayaText en parsant les marqueurs ۝١٠ pour les rendre en vert.
  Widget _buildAyaRichText(String ayaText) {
    // Regex : ۝ (U+06DD) suivi de chiffres arabo-indics ٠-٩
    final pattern = RegExp(r'۝([٠-٩]+)');
    final matches = pattern.allMatches(ayaText).toList();

    if (matches.isEmpty) {
      return Text(
        ayaText,
        style: AppTheme.warshVerse(size: 19),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: ayaText.substring(lastIndex, match.start),
          style: AppTheme.warshVerse(size: 19),
        ));
      }
      // Convertir les chiffres arabo-indics en entier
      final arabicDigits = match.group(1)!;
      const arabicZero = 0x0660;
      final num = int.parse(
        String.fromCharCodes(arabicDigits.runes.map((r) => r - arabicZero + 48)),
      );
      spans.add(_verseCircleSpan(num));
      lastIndex = match.end;
    }

    if (lastIndex < ayaText.length) {
      spans.add(TextSpan(
        text: ayaText.substring(lastIndex),
        style: AppTheme.warshVerse(size: 19),
      ));
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontFamily: 'WarshKFGQPC'),
        children: spans,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
  }
}

class _RepetitionBadge extends StatelessWidget {
  final int current;
  final int target;
  final bool manualDone;

  const _RepetitionBadge({
    required this.current,
    required this.target,
    this.manualDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = manualDone || current >= target;
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
  final bool manualDone;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const _CounterButton({
    required this.current,
    required this.target,
    required this.onTap,
    required this.onReset,
    this.manualDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = manualDone || current >= target;
    final showReset = manualDone || current > 0;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              decoration: BoxDecoration(
                color: done
                    ? AppTheme.gold
                    : AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: done
                      ? AppTheme.gold
                      : AppTheme.primaryGreen.withValues(alpha: 0.35),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.touch_app_outlined,
                      color: done ? Colors.white : AppTheme.primaryGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      done ? 'قُرِئَ ✓' : 'عدّ ($current/$target)',
                      style: TextStyle(
                        color: done ? Colors.white : AppTheme.primaryGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showReset) ...[
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

// ─────────────────────────────────────────────────────────────────────────────
// Bouton "بالسبحة" — marquer terminé sans utiliser le compteur
// ─────────────────────────────────────────────────────────────────────────────
// Bouton "تم بالسبحة" — nécessite un appui long pour éviter les clics accidentels
// ─────────────────────────────────────────────────────────────────────────────
class _TasbihaButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TasbihaButton({required this.onTap});

  @override
  State<_TasbihaButton> createState() => _TasbihaButtonState();
}

class _TasbihaButtonState extends State<_TasbihaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdController;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _holding) {
          HapticFeedback.mediumImpact();
          widget.onTap();
        }
      });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onLongPressStart(_) {
    setState(() => _holding = true);
    _holdController.forward(from: 0);
  }

  void _onLongPressEnd(_) {
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
    setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: () {
        _holdController.reverse();
        setState(() => _holding = false);
      },
      child: AnimatedBuilder(
        animation: _holdController,
        builder: (context, _) {
          final progress = _holdController.value;
          return Container(
            height: 38,
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.teal.shade50,
                Colors.teal.shade200,
                progress,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.shade200),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Barre de progression
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    color: Colors.teal.shade100.withValues(alpha: 0.6),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grain, color: Colors.teal.shade600, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _holding ? 'تم بالسبحة…' : 'تم بالسبحة  ◌',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton simple "تم القراءة" pour les items à lecture unique
// ─────────────────────────────────────────────────────────────────────────────
class _ReadToggleButton extends StatelessWidget {
  final bool isDone;
  final VoidCallback onToggle;

  const _ReadToggleButton({required this.isDone, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: isDone ? AppTheme.gold : AppTheme.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDone ? AppTheme.gold : AppTheme.primaryGreen.withValues(alpha: 0.35),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.circle_outlined,
                color: isDone ? Colors.white : AppTheme.primaryGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isDone ? 'قُرِئَ ✓' : 'تم القراءة',
                style: TextStyle(
                  color: isDone ? Colors.white : AppTheme.primaryGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
