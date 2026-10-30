import 'word.dart';

class Kalma {
  final int number;
  final String english; // e.g. "First Kalma"
  final String transliteration; // e.g. "Tayyab"
  final String urduName;
  final List<Word> words;

  const Kalma({
    required this.number,
    required this.english,
    required this.transliteration,
    required this.urduName,
    required this.words,
  });

  String get fullArabic => words.map((w) => w.arabic).join(' ');
  String get previewArabic => words.first.arabic;
}
