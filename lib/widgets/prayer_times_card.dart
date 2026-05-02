import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  DayPrayerTimes? _times;
  bool _loading = true;
  bool _locationError = false;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _locationError = false; });
    try {
      final times = await PrayerTimesService.instance.getToday();
      if (mounted) setState(() { _times = times; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _locationError = true; });
    }
  }

  Future<void> _requestLocation() async {
    setState(() { _loading = true; _locationError = false; });
    final ok = await PrayerTimesService.instance.requestAndSaveLocation();
    if (!mounted) return;
    if (ok) {
      await _load();
    } else {
      setState(() { _loading = false; _locationError = true; });
    }
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
                  const Icon(Icons.access_time, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مواقيت الصلاة',
                      style: AppTheme.arabicTitle(size: 16, color: AppTheme.primaryGreen),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location, size: 18, color: AppTheme.primaryGreen),
                    tooltip: 'تحديد الموقع',
                    onPressed: _requestLocation,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_locationError)
                _buildError()
              else if (_times != null)
                _buildGrid(_times!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        Text(
          'تعذّر تحديد موقعك. يُستخدم موقع فاس افتراضياً.',
          style: AppTheme.arabicBody(size: 13, color: Colors.red.shade700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _requestLocation,
          icon: const Icon(Icons.refresh, size: 16),
          label: Text('إعادة المحاولة', style: AppTheme.arabicBody(size: 13)),
        ),
      ],
    );
  }

  Widget _buildGrid(DayPrayerTimes t) {
    final prayers = [
      _PrayerEntry('الفجر',   Icons.brightness_3,       t.fajr,    Colors.indigo),
      _PrayerEntry('الشروق',  Icons.wb_twilight,          t.sunrise, Colors.orange.shade300),
      _PrayerEntry('الضحى',   Icons.wb_sunny_outlined,    t.duha,    Colors.amber),
      _PrayerEntry('الظهر',   Icons.wb_sunny,             t.dhuhr,   Colors.orange),
      _PrayerEntry('العصر',   Icons.light_mode_outlined,  t.asr,     Colors.deepOrange),
      _PrayerEntry('المغرب',  Icons.nightlight_round,     t.maghrib, const Color(0xFF4A235A)),
      _PrayerEntry('العشاء',  Icons.bedtime,              t.isha,    Colors.indigo.shade900),
    ];

    int nextIdx = -1;
    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].time.isAfter(_now)) {
        nextIdx = i;
        break;
      }
    }
    final int currentIdx = nextIdx > 0
        ? nextIdx - 1
        : (nextIdx == -1 ? prayers.length - 1 : -1);

    String? countdown;
    String? nextName;
    if (nextIdx >= 0) {
      final diff = prayers[nextIdx].time.difference(_now);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      final s = diff.inSeconds % 60;
      if (h > 0) {
        countdown = '$hس ${m.toString().padLeft(2, '0')}د';
      } else if (m > 0) {
        countdown = '$mد ${s.toString().padLeft(2, '0')}ث';
      } else {
        countdown = '${diff.inSeconds}ث';
      }
      nextName = prayers[nextIdx].name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (countdown != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryGreen),
                const SizedBox(width: 6),
                Text(
                  '$nextName بعد ',
                  style: AppTheme.arabicBody(size: 13, color: AppTheme.primaryGreen),
                ),
                Text(
                  countdown,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < prayers.length; i++)
              _PrayerChip(
                entry: prayers[i],
                isCurrent: i == currentIdx,
                isNext: i == nextIdx,
              ),
          ],
        ),
      ],
    );
  }
}

class _PrayerEntry {
  final String name;
  final IconData icon;
  final DateTime time;
  final Color color;
  const _PrayerEntry(this.name, this.icon, this.time, this.color);
}

class _PrayerChip extends StatelessWidget {
  final _PrayerEntry entry;
  final bool isCurrent;
  final bool isNext;

  const _PrayerChip({
    required this.entry,
    required this.isCurrent,
    required this.isNext,
  });

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isCurrent
            ? entry.color.withValues(alpha: 0.20)
            : isNext
                ? entry.color.withValues(alpha: 0.12)
                : entry.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? entry.color.withValues(alpha: 0.65)
              : isNext
                  ? entry.color.withValues(alpha: 0.40)
                  : entry.color.withValues(alpha: 0.15),
          width: isCurrent ? 2.0 : (isNext ? 1.5 : 1.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entry.icon, color: entry.color, size: 15),
          const SizedBox(width: 5),
          Text(
            entry.name,
            style: AppTheme.arabicBody(size: 12, color: AppTheme.darkBrown),
          ),
          const SizedBox(width: 5),
          Text(
            _fmt(entry.time),
            style: TextStyle(
              fontSize: 12,
              fontWeight: (isCurrent || isNext) ? FontWeight.bold : FontWeight.normal,
              color: entry.color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: entry.color,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'الآن',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
