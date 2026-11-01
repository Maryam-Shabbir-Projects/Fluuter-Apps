import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Settings and history. Saved on the device only; nothing is uploaded.
class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore I = AppStore._();

  late SharedPreferences _p;
  bool onboarded = false, beep = true, vibrate = true, saveHistory = true, autoOpen = false;
  List<HistoryItem> items = [];

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    onboarded = _p.getBool('onboarded') ?? false;
    beep = _p.getBool('beep') ?? true;
    vibrate = _p.getBool('vibrate') ?? true;
    saveHistory = _p.getBool('saveHistory') ?? true;
    autoOpen = _p.getBool('autoOpen') ?? false;
    final s = _p.getString('history');
    if (s != null) {
      items = (jsonDecode(s) as List)
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> set(String key, bool v) async {
    switch (key) {
      case 'onboarded': onboarded = v;
      case 'beep': beep = v;
      case 'vibrate': vibrate = v;
      case 'saveHistory': saveHistory = v;
      case 'autoOpen': autoOpen = v;
    }
    await _p.setBool(key, v);
    notifyListeners();
  }

  void add(String raw, {required bool created}) {
    if (!saveHistory) return;
    if (items.isNotEmpty && items.first.raw == raw && items.first.created == created) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    items.insert(0, HistoryItem('$now', raw, created, now));
    if (items.length > 200) items = items.sublist(0, 200);
    _persist();
  }

  void remove(HistoryItem i) {
    items.removeWhere((e) => e.id == i.id);
    _persist();
  }

  void clear() {
    items = [];
    _persist();
  }

  void _persist() {
    _p.setString('history', jsonEncode(items.map((e) => e.toJson()).toList()));
    notifyListeners();
  }
}
