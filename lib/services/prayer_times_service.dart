import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Horaires de prière pour un jour donné (heure locale de l'appareil)
class DayPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;

  /// صلاة الضحى — 20 min après le lever du soleil (début du temps)
  final DateTime duha;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  final double latitude;
  final double longitude;

  const DayPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.duha,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.latitude,
    required this.longitude,
  });

  /// Heure du ورد الصباح : Fajr + 30 min
  DateTime get fajrWird => fajr.add(const Duration(minutes: 30));

  /// Heure du ورد المساء : Maghrib + 20 min
  DateTime get maghribWird => maghrib.add(const Duration(minutes: 20));
}

class PrayerTimesService {
  PrayerTimesService._();
  static final instance = PrayerTimesService._();

  // Tunis, Tunisie — coordonnées par défaut
  static const double _defaultLat = 36.8065;
  static const double _defaultLng = 10.1815;

  static const String _kLat = 'prayer_lat';
  static const String _kLng = 'prayer_lng';

  // ── Coordonnées ─────────────────────────────────────────────────────────

  Future<(double lat, double lng)> getSavedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      prefs.getDouble(_kLat) ?? _defaultLat,
      prefs.getDouble(_kLng) ?? _defaultLng,
    );
  }

  Future<void> saveCoordinates(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLat, lat);
    await prefs.setDouble(_kLng, lng);
  }

  /// Demande la permission de localisation et sauvegarde les coordonnées GPS.
  /// Retourne `true` si la localisation a été obtenue avec succès.
  Future<bool> requestAndSaveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.reduced,
        ),
      ).timeout(const Duration(seconds: 10));

      await saveCoordinates(pos.latitude, pos.longitude);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Calcul ──────────────────────────────────────────────────────────────

  DayPrayerTimes _calculate(double lat, double lng, DateTime date) {
    final coordinates = Coordinates(lat, lng);
    final dateComponents = DateComponents.from(date);

    // المنهج: رابطة العالم الإسلامي — الفجر 18°، العشاء 17° (يطابق المغرب)
    final params = CalculationMethod.muslim_world_league.getParameters();
    // العصر على المذهب المالكي (مثل الحنفي: ظل = 2×)
    params.madhab = Madhab.hanafi;

    // utcOffset = null → sorties en heure locale de l'appareil
    final times = PrayerTimes(coordinates, dateComponents, params);

    return DayPrayerTimes(
      fajr: times.fajr,
      sunrise: times.sunrise,
      duha: times.sunrise.add(const Duration(minutes: 20)),
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      latitude: lat,
      longitude: lng,
    );
  }

  Future<DayPrayerTimes> getToday() async {
    final (lat, lng) = await getSavedCoordinates();
    return _calculate(lat, lng, DateTime.now());
  }

  /// Retourne les horaires pour les [count] prochains jours (à partir d'aujourd'hui)
  Future<List<DayPrayerTimes>> getNextDays(int count) async {
    final (lat, lng) = await getSavedCoordinates();
    final today = DateTime.now();
    return [
      for (int i = 0; i < count; i++)
        _calculate(lat, lng, today.add(Duration(days: i))),
    ];
  }
}
