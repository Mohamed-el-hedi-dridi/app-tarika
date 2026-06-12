import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/custom_dhikr.dart';
import '../providers/custom_dhikr_provider.dart';
import '../services/sound_service.dart';
import '../widgets/islamic_header.dart';

class CustomDhikrScreen extends StatelessWidget {
  const CustomDhikrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Consumer<CustomDhikrProvider>(
          builder: (context, provider, _) {
            final items = provider.items;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: IslamicHeader(
                    title: 'أذكاري الخاصة',
                    subtitle: 'أضف ذكرك وتابعه بإذن الله',
                    trailing: _buildBadge(items.length),
                    showBack: true,
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CustomDhikrCard(
                        dhikr: items[index],
                        index: index,
                      ),
                      childCount: items.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, null),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'إضافة ذكر',
          style: AppTheme.arabicBody(size: 15, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        count == 0 ? 'لا يوجد بعد' : '$count أذكار',
        style: AppTheme.arabicVerse(size: 14, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Future<void> _showForm(
      BuildContext context, CustomDhikr? existing) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DhikrFormSheet(existing: existing),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte d'un dhikr personnalisé avec compteur
// ─────────────────────────────────────────────────────────────────────────────

class _CustomDhikrCard extends StatefulWidget {
  final CustomDhikr dhikr;
  final int index;

  const _CustomDhikrCard({required this.dhikr, required this.index});

  @override
  State<_CustomDhikrCard> createState() => _CustomDhikrCardState();
}

class _CustomDhikrCardState extends State<_CustomDhikrCard>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  bool _done = false;

  late AnimationController _tickCtrl;
  late Animation<double> _tickScale;
  late Animation<double> _tickOpacity;

  @override
  void initState() {
    super.initState();
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _tickScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
    ]).animate(_tickCtrl);
    _tickOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_tickCtrl);
    _tickCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) _tickCtrl.reset();
    });
  }

  @override
  void dispose() {
    _tickCtrl.dispose();
    super.dispose();
  }

  void _increment() {
    if (_done) return;
    final target = widget.dhikr.repetitions;
    setState(() => _count++);
    HapticFeedback.lightImpact();
    if (_count >= target) {
      _done = true;
      HapticFeedback.heavyImpact();
      SoundService.playDone();
      _tickCtrl.forward(from: 0);
    }
  }

  void _reset() {
    setState(() {
      _count = 0;
      _done = false;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.dhikr.repetitions;
    final isCompleted = _done || _count >= target;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.lightGold.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppTheme.gold
              : AppTheme.borderGold.withValues(alpha: 0.3),
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
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.gold.withValues(alpha: 0.2)
                    : AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  // Numéro / check
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.gold
                          : AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
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
                  // Titre
                  Expanded(
                    child: Text(
                      widget.dhikr.title,
                      style: AppTheme.arabicTitle(
                          size: 17, color: AppTheme.primaryGreen),
                    ),
                  ),
                  // Badge répétitions
                  if (target > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.gold
                            : AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted
                            ? '$target/$target'
                            : '$_count/$target',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Bouton modifier
                  _ActionIconButton(
                    icon: Icons.edit_outlined,
                    color: AppTheme.primaryGreen,
                    tooltip: 'تعديل',
                    onTap: () =>
                        CustomDhikrScreen._showForm(context, widget.dhikr),
                  ),
                  // Bouton supprimer
                  _ActionIconButton(
                    icon: Icons.delete_outline,
                    color: Colors.red.shade400,
                    tooltip: 'حذف',
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),

            // ── Corps du dhikr ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                widget.dhikr.text,
                style: AppTheme.arabicVerse(size: 19),
                textAlign: TextAlign.center,
              ),
            ),

            // ── Contrôles (compteur ou simple case à cocher) ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: target > 1
                  ? _CounterRow(
                      count: _count,
                      target: target,
                      done: isCompleted,
                      onTap: _increment,
                      onReset: _reset,
                      tickCtrl: _tickCtrl,
                      tickScale: _tickScale,
                      tickOpacity: _tickOpacity,
                    )
                  : _SimpleToggle(
                      done: isCompleted,
                      onToggle: () {
                        if (!isCompleted) {
                          _increment();
                        } else {
                          _reset();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف الذكر',
            style: AppTheme.arabicTitle(size: 18),
          ),
          content: Text(
            'هل تريد حذف "${widget.dhikr.title}"؟',
            style: AppTheme.arabicBody(size: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  Text('إلغاء', style: AppTheme.arabicBody(size: 15)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'حذف',
                style: AppTheme.arabicBody(
                    size: 15, color: Colors.red.shade600),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CustomDhikrProvider>().delete(widget.dhikr.id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rangée de compteur
// ─────────────────────────────────────────────────────────────────────────────

class _CounterRow extends StatelessWidget {
  final int count;
  final int target;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final AnimationController tickCtrl;
  final Animation<double> tickScale;
  final Animation<double> tickOpacity;

  const _CounterRow({
    required this.count,
    required this.target,
    required this.done,
    required this.onTap,
    required this.onReset,
    required this.tickCtrl,
    required this.tickScale,
    required this.tickOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton reset
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded),
          color: AppTheme.primaryGreen.withValues(alpha: 0.6),
          iconSize: 22,
          tooltip: 'إعادة',
        ),
        const Spacer(),
        // Bouton compteur principal
        GestureDetector(
          onTap: done ? null : onTap,
          child: AnimatedBuilder(
            animation: tickCtrl,
            builder: (_, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  child!,
                  if (tickCtrl.isAnimating)
                    Opacity(
                      opacity: tickOpacity.value,
                      child: Transform.scale(
                        scale: tickScale.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: AppTheme.gold, size: 28),
                        ),
                      ),
                    ),
                ],
              );
            },
            child: Container(
              height: 52,
              constraints: const BoxConstraints(minWidth: 120),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: done
                      ? [AppTheme.gold, AppTheme.gold.withValues(alpha: 0.8)]
                      : [AppTheme.primaryGreen, AppTheme.lightGreen],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: (done ? AppTheme.gold : AppTheme.primaryGreen)
                        .withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_circle,
                        color: Colors.white, size: 26)
                    : Text(
                        'سبّح  ·  $count / $target',
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
        const Spacer(),
        const SizedBox(width: 40), // équilibre avec reset
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton simple (1 répétition)
// ─────────────────────────────────────────────────────────────────────────────

class _SimpleToggle extends StatelessWidget {
  final bool done;
  final VoidCallback onToggle;

  const _SimpleToggle({required this.done, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: done ? AppTheme.gold : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (done ? AppTheme.gold : AppTheme.primaryGreen)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                done ? 'تمّ' : 'تمّ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icône d'action (modifier / supprimer)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État vide
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome,
                size: 72,
                color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            const SizedBox(height: 20),
            Text(
              'لم تضف أي ذكر بعد',
              style: AppTheme.arabicTitle(
                  size: 18,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'اضغط على زر الإضافة لإضافة ذكرك الخاص',
              style: AppTheme.arabicBody(
                  size: 15,
                  color: AppTheme.darkBrown.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formulaire d'ajout / modification (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _DhikrFormSheet extends StatefulWidget {
  final CustomDhikr? existing;

  const _DhikrFormSheet({this.existing});

  @override
  State<_DhikrFormSheet> createState() => _DhikrFormSheetState();
}

class _DhikrFormSheetState extends State<_DhikrFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _textCtrl;
  late TextEditingController _repCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _textCtrl = TextEditingController(text: widget.existing?.text ?? '');
    _repCtrl = TextEditingController(
        text: '${widget.existing?.repetitions ?? 1}');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    _repCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<CustomDhikrProvider>();
    final reps = int.tryParse(_repCtrl.text.trim()) ?? 1;

    if (widget.existing == null) {
      final dhikr = CustomDhikr(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        text: _textCtrl.text.trim(),
        repetitions: reps.clamp(1, 9999),
      );
      await provider.add(dhikr);
    } else {
      await provider.update(widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        text: _textCtrl.text.trim(),
        repetitions: reps.clamp(1, 9999),
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.borderGold.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Titre du sheet
                Text(
                  isEdit ? 'تعديل الذكر' : 'إضافة ذكر جديد',
                  style: AppTheme.arabicTitle(
                      size: 20, color: AppTheme.primaryGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Champ titre
                _buildField(
                  controller: _titleCtrl,
                  label: 'العنوان',
                  hint: 'مثال: تسبيح ما بعد الصلاة',
                  icon: Icons.title,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل العنوان' : null,
                ),
                const SizedBox(height: 14),

                // Champ texte/corps
                _buildField(
                  controller: _textCtrl,
                  label: 'نص الذكر',
                  hint: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ...',
                  icon: Icons.format_quote,
                  maxLines: 4,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل نص الذكر' : null,
                ),
                const SizedBox(height: 14),

                // Champ répétitions
                _buildField(
                  controller: _repCtrl,
                  label: 'عدد المرات',
                  hint: '33',
                  icon: Icons.repeat,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل العدد';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1) return 'يجب أن يكون العدد ≥ 1';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Bouton enregistrer
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isEdit ? 'حفظ التعديلات' : 'إضافة الذكر',
                          style: AppTheme.arabicBody(
                              size: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: AppTheme.arabicBody(size: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        labelStyle: AppTheme.arabicBody(size: 14, color: AppTheme.primaryGreen),
        hintStyle: AppTheme.arabicBody(
            size: 14, color: AppTheme.darkBrown.withValues(alpha: 0.4)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppTheme.borderGold.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppTheme.borderGold.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
