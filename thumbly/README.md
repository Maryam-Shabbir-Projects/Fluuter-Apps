# Thumbly

A Flutter app for designing YouTube thumbnails and social media graphics on your phone. Pick a frame size, add text, icons, shapes and photos to a layered canvas, and export a finished PNG. No account and no internet connection needed.

## Features

- **Five frame presets:** YouTube thumbnail (1280x720), Square post (1080x1080), Portrait post (1080x1350), Story / Reel (1080x1920) and Wide banner (1500x500).
- **Layered canvas editor:** tap to select, drag to move, use the handles to resize. Reorder layers, duplicate or delete elements.
- **Element library:** styled text with a font picker, an icon catalog, built-in shapes and imported photos.
- **Background removal:** cuts a subject out of a photo as a transparent PNG, processed on-device.
- **Backgrounds:** solid colours, gradients or a custom image.
- **Image adjustments:** an adjust sheet for fine-tuning photos.
- **Undo history** while editing.
- **Auto-save and My designs:** work is saved when you leave the editor. Rename, duplicate or delete designs from the home screen.
- **Export:** renders the canvas to a full-resolution PNG and opens the system share sheet.
- **Light and dark themes** (Material 3).

## App flow

1. **Welcome screen:** logo, tagline and a Get started button.
2. **Home screen:** choose a frame size, tap the blank canvas to start, or reopen a saved design.
3. **Editor screen:** build the design with the Text, Icons, Shapes, Images and Background tabs, then save or export.

## Project structure

```
lib/
  main.dart                  App entry point, theme and storage setup
  core/
    theme.dart               Brand colours and Material 3 theme
  data/
    catalog.dart             Icon, shape and font catalog
  models/
    design.dart              Design, Doc and frame presets
    element_model.dart       Canvas element data (text, icon, shape, image)
  screens/
    welcome_screen.dart      First screen
    home_screen.dart         Frame picker and saved designs
    editor/
      editor_screen.dart     Main editor: gestures, undo, save, export
      panels.dart            Text, Icons, Shapes, Images and Background panels
  services/
    storage_service.dart     Saves designs and imported photos locally
    export_service.dart      Captures the canvas as PNG and shares it
    bg_remove_service.dart   On-device background removal
  widgets/
    stage.dart               Renders the canvas and selection handles
    shapes.dart              Shape drawing
    sheets.dart              Bottom sheets (size, adjust, font, colour)
    quick_bar.dart           Action bar for the selected element
    dialogs.dart             Prompt and confirm dialogs
```

## Tech stack

| Area | Package |
| --- | --- |
| Framework | Flutter (Dart), Material 3 |
| Fonts | `google_fonts` |
| Photo import | `image_picker` |
| Background removal | `image_background_remover` |
| Local files | `path_provider` |
| Sharing / export | `share_plus` |

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Place the `lib/` folder in a Flutter project (`flutter create thumbly`).
3. Add the dependencies from the table above to `pubspec.yaml`:
   ```
   flutter pub add google_fonts image_picker image_background_remover path_provider share_plus
   ```
4. Run the app:
   ```
   flutter pub get
   flutter run
   ```

Photo import may need platform permissions. Follow the `image_picker` setup notes for Android and iOS.

## How it works

- **Resolution-independent canvas:** designs are authored in real pixel dimensions (for example 1280x720) and scaled to fit the screen, so hit-testing stays accurate and export is full size on any device.
- **Local-first storage:** each design is saved as `<id>.json` plus a `<id>.png` preview in `<app documents>/thumbly/designs`. Imported photos are copied to `<app documents>/thumbly/media`, so designs keep working if the original photo is deleted.
- **Export:** the canvas is captured from a `RepaintBoundary` as a PNG at the frame's full width, then handed to the share sheet (choose Save to gallery or Files).
- **Privacy:** background removal runs entirely on the device.

## Roadmap ideas

- Ready-made templates
- JPG export and custom sizes
- More text effects and blend modes
- Cloud backup

## License

Add your license here.
