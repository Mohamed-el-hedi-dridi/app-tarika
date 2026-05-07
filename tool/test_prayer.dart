import 'package:adhan/adhan.dart';

void main() {
  final lat = 36.81897;
  final lng = 10.16579;
  final date = DateTime.now();
  final coords = Coordinates(lat, lng);
  final params = CalculationMethod.muslim_world_league.getParameters();
  params.madhab = Madhab.hanafi;
  final dt = DateComponents.from(date);
  final times = PrayerTimes(coords, dt, params);
  final timesOffset = PrayerTimes(coords, dt, params, utcOffset: date.timeZoneOffset);
  print('now local: $date');
  print('local offset: ${date.timeZoneOffset}');
  print('fajr local: ${times.fajr}');
  print('sunrise local: ${times.sunrise}');
  print('dhuhr local: ${times.dhuhr}');
  print('asr local: ${times.asr}');
  print('maghrib local: ${times.maghrib}');
  print('isha local: ${times.isha}');
  print('---');
  print('fajr offset: ${timesOffset.fajr}');
  print('sunrise offset: ${timesOffset.sunrise}');
  print('dhuhr offset: ${timesOffset.dhuhr}');
  print('asr offset: ${timesOffset.asr}');
  print('maghrib offset: ${timesOffset.maghrib}');
  print('isha offset: ${timesOffset.isha}');
}
