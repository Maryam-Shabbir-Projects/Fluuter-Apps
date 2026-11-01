import 'dart:convert';

class Entry {
  final String value;
  final String format;
  final bool created;
  final DateTime time;

  Entry(this.value, this.format, this.created, [DateTime? time]) : time = time ?? DateTime.now();

  String get timeLabel => time.toString().substring(0, 16);

  String toJson() => jsonEncode({'v': value, 'f': format, 'c': created, 't': time.toIso8601String()});

  factory Entry.fromJson(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return Entry(m['v'], m['f'], m['c'], DateTime.parse(m['t']));
  }
}
