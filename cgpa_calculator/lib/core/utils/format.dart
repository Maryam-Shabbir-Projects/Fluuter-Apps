String fmt(double v, [int digits = 2]) => v.toStringAsFixed(digits);

/// 3.0 -> "3", 2.5 -> "2.5"
String fmtNum(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

String newId() => DateTime.now().microsecondsSinceEpoch.toString();
