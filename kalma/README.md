# The Six Kalmas

A Flutter app to read, learn and understand the six kalmas in Arabic with word-by-word Urdu meaning.

## Features

- All six kalmas: Tayyab, Shahadat, Tamjeed, Tauheed, Astaghfar and Radd-e-Kufr.
- Full Arabic text with diacritics, shown large and right-to-left.
- Word-by-word Urdu meaning next to each Arabic phrase (43 phrases in total).
- Kalma list with numbered cards and an Arabic preview.
- Previous and Next buttons on each kalma page.
- English labels with Urdu titles throughout.
- Star emblem drawn in code, so there are no image assets.
- Material 3 light theme in green, gold and ivory.

## Screens

1. **Landing:** emblem, Urdu and English title, short description and a Start Reading button.
2. **Kalma list:** cards for all six kalmas. Tap one to open it.
3. **Kalma detail:** the full Arabic text, the word-by-word table, and Previous / Next navigation.

## Project structure

```
lib/
  main.dart                      Entry point
  app.dart                       MaterialApp, title and theme
  core/theme/
    app_colors.dart              Green, gold and ivory palette
    app_text_styles.dart         Amiri, Noto Nastaliq Urdu and Inter styles
    app_theme.dart               Material 3 theme
  data/
    kalma_data.dart              The six kalmas and their word meanings
  models/
    kalma.dart                   Kalma: number, names and words
    word.dart                    Word: Arabic text and Urdu meaning
  screens/
    landing/landing_screen.dart
    kalma_list/kalma_list_screen.dart
    kalma_detail/kalma_detail_screen.dart
  widgets/
    kalma_card.dart              List card
    screen_header.dart           Green header bar
    star_emblem.dart             CustomPaint star emblem
    word_meaning_row.dart        Arabic and Urdu row
```

## Tech stack

| Area | Technology |
| --- | --- |
| Framework | Flutter (Dart), Material 3 |
| Fonts | `google_fonts` (Amiri, Noto Nastaliq Urdu, Inter) |
| Graphics | `CustomPaint` |
| Navigation | `Navigator` with `MaterialPageRoute` |

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Create a project and replace its `lib/` folder with this one:
   ```
   flutter create six_kalmas
   ```
3. Add the font package:
   ```
   flutter pub add google_fonts
   ```
4. Run the app:
   ```
   flutter run
   ```

`google_fonts` downloads fonts the first time they are used, so the first launch needs an internet connection. To work fully offline, bundle the fonts as assets as described in the `google_fonts` documentation.

## Adding or editing content

All text lives in `lib/data/kalma_data.dart`. Each `Kalma` has a number, English name, transliteration, Urdu name and a list of `Word(arabic, urdu)` pairs. Edit that list and the screens update automatically.

Please have any religious text reviewed by a qualified person before publishing.

## License

 license here.

 <img width="2400" height="1254" alt="kalma" src="https://github.com/user-attachments/assets/689ea050-2b04-4212-a2ef-6bf70e9aa183" />

