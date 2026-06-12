import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_dhikr.dart';

class CustomDhikrProvider extends ChangeNotifier {
  static const _kKey = 'custom_dhikr_list';

  List<CustomDhikr> _items = [];

  List<CustomDhikr> get items => List.unmodifiable(_items);

  CustomDhikrProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kKey);
    if (json != null && json.isNotEmpty) {
      try {
        _items = CustomDhikr.listFromJson(json);
        notifyListeners();
      } catch (_) {
        _items = [];
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, CustomDhikr.listToJson(_items));
  }

  Future<void> add(CustomDhikr dhikr) async {
    _items.add(dhikr);
    notifyListeners();
    await _save();
  }

  Future<void> update(CustomDhikr dhikr) async {
    final index = _items.indexWhere((e) => e.id == dhikr.id);
    if (index == -1) return;
    _items[index] = dhikr;
    notifyListeners();
    await _save();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }
}
