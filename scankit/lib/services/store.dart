import 'package:flutter/foundation.dart';
import 'package:scankit/models/entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings and history, persisted with SharedPreferences.
class Store extends ChangeNotifier {
  Store._();
  static final Store i = Store._();

  late SharedPreferences _p;
  List<Entry> items = [];
  bool beep = true, vibrate = true, save = true, welcomed = false;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    beep = _p.getBool('beep') ?? true;
    vibrate = _p.getBool('vibrate') ?? true;
    save = _p.getBool('save') ?? true;
    welcomed = _p.getBool('welcomed') ?? false;
    items = (_p.getStringList('h') ?? []).map(Entry.fromJson).toList();
  }

  void setFlag(String key, bool value) {
    switch (key) {
      case 'beep':
        beep = value;
      case 'vibrate':
        vibrate = value;
      case 'save':
        save = value;
      case 'welcomed':
        welcomed = value;
    }
    _p.setBool(key, value);
    notifyListeners();
  }

  void add(Entry e) {
    if (!save) return;
    items.insert(0, e);
    if (items.length > 200) items.removeLast();
    _persist();
  }

  void clear() {
    items.clear();
    _persist();
  }

  List<Entry> byType({required bool created}) => items.where((e) => e.created == created).toList();

  void _persist() {
    _p.setStringList('h', items.map((e) => e.toJson()).toList());
    notifyListeners();
  }
}
