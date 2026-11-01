import 'package:flutter/material.dart';

/// Change the app name here (also change it in AndroidManifest / Info.plist).
const kAppName = 'NoteLeaf';

/// (font family, group). Groups are shown as headings in the font picker.
const kFontList = [
  ('Noto Nastaliq Urdu', 'Urdu / Arabic'), ('Noto Naskh Arabic', 'Urdu / Arabic'), ('Amiri', 'Urdu / Arabic'), ('Lateef', 'Urdu / Arabic'),
  ('Scheherazade New', 'Urdu / Arabic'), ('Reem Kufi', 'Urdu / Arabic'), ('Aref Ruqaa', 'Urdu / Arabic'), ('Cairo', 'Urdu / Arabic'),
  ('Noto Sans Devanagari', 'Hindi'), ('Hind', 'Hindi'), ('Kalam', 'Hindi'),
  ('Roboto', 'English'), ('Poppins', 'English'), ('Lora', 'English'), ('Merriweather', 'English'), ('Playfair Display', 'English'),
  ('Dancing Script', 'Cursive'), ('Pacifico', 'Cursive'), ('Great Vibes', 'Cursive'), ('Satisfy', 'Cursive'),
  ('Sacramento', 'Cursive'), ('Parisienne', 'Cursive'), ('Kaushan Script', 'Cursive'), ('Caveat', 'Cursive'),
];
final kFonts = [for (final f in kFontList) f.$1];

/// Font sizes in points, like a word processor. 1 pt = page short side / 540 pixels.
const kPts = <double>[8, 9, 10, 11, 12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 48, 60, 72, 96];

const kSizes = {
  'YouTube long 16:9': Size(1920, 1080),
  'Shorts 9:16': Size(1080, 1920),
  'Square 1:1': Size(1080, 1080),
  'Post 4:5': Size(1080, 1350),
  'A4': Size(1240, 1754),
};

const kPalette = [
  0xFF000000, 0xFF424242, 0xFF9E9E9E, 0xFFFFFFFF, 0xFFB3261E, 0xFFE53935, 0xFFFF7043, 0xFFFFA726,
  0xFFFFD54F, 0xFFF6EBCF, 0xFF9CCC65, 0xFF2E7D32, 0xFF0F766E, 0xFF26C6DA, 0xFF1E88E5, 0xFF1D4ED8,
  0xFF283593, 0xFF5E35B1, 0xFF8E24AA, 0xFFD81B60, 0xFFF8BBD0, 0xFF8D6E63, 0xFF3E2723, 0xFF0B1020,
];

/// Ready-made two-colour gradients for paper.
const kGradients = [
  [0xFFFFD6A5, 0xFFFF9AA2], [0xFF38BDF8, 0xFF1E3A8A], [0xFF84FAB0, 0xFF8FD3F4],
  [0xFFFBC2EB, 0xFFA6C1EE], [0xFFF6D365, 0xFFFDA085], [0xFF232526, 0xFF414345],
];

/// Voice typing languages (matched against what the phone offers).
const kVoiceLocales = {'ur_PK': 'Urdu', 'hi_IN': 'Hindi', 'en_US': 'English', 'ar_SA': 'Arabic', 'pa_IN': 'Punjabi'};

enum PaperPattern { none, lines, grid, dots, frame }

class Paper {
  final String name;
  final List<Color> bg;
  final Color fg;
  final PaperPattern pat;
  final bool radial;
  const Paper(this.name, this.bg, this.fg, {this.pat = PaperPattern.none, this.radial = false});
}

const kPapers = [
  Paper('Parchment', [Color(0xFFF6EBCF), Color(0xFFE8D3A2)], Color(0xFF3B2A14)),
  Paper('Ruled', [Color(0xFFFFFDF3), Color(0xFFF6F1DD)], Color(0xFF1F2A44), pat: PaperPattern.lines),
  Paper('Graph', [Color(0xFFF2FAF5), Color(0xFFDDEFE4)], Color(0xFF14281F), pat: PaperPattern.grid),
  Paper('Dotted', [Color(0xFFFBF7EA), Color(0xFFF1E9D0)], Color(0xFF2E2410), pat: PaperPattern.dots),
  Paper('White', [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], Color(0xFF111111)),
  Paper('Midnight', [Color(0xFF2A3C6B), Color(0xFF0B1020)], Color(0xFFF3F1E4), radial: true),
  Paper('Ocean', [Color(0xFF38BDF8), Color(0xFF1D4ED8), Color(0xFF1E1B4B)], Color(0xFFFFFFFF)),
  Paper('Sunset', [Color(0xFFFFD6A5), Color(0xFFFF9AA2), Color(0xFFC77DFF)], Color(0xFF2B1030)),
  Paper('Rose', [Color(0xFFFFE3EA), Color(0xFFFFC3D4)], Color(0xFF4A1226)),
  Paper('Forest', [Color(0xFF2F6B52), Color(0xFF0F2C22)], Color(0xFFEAF5EC)),
  Paper('Slate', [Color(0xFFDDE6EE), Color(0xFFC3D2E0)], Color(0xFF14222F)),
  Paper('Vintage', [Color(0xFFF3E6C8), Color(0xFFE2CB97)], Color(0xFF3B2A14), pat: PaperPattern.frame),
  Paper('Kraft', [Color(0xFFDDBF8F), Color(0xFFC49A66)], Color(0xFF3A2410)),
];

/// Short names for the page size cards: (title, subtitle).
const kSizeLabels = {
  'YouTube long 16:9': ('YouTube', '16:9'),
  'Shorts 9:16': ('Shorts', '9:16'),
  'Square 1:1': ('Square', '1:1'),
  'Post 4:5': ('Post', '4:5'),
  'A4': ('A4', 'Print'),
};
