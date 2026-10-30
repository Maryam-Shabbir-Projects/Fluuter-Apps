import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_background_remover/image_background_remover.dart';

import 'storage_service.dart';

/// On-device background removal (no internet needed). Result is a transparent PNG.
class BgRemoveService {
  static bool _ready = false;

  /// Encoded image bytes in, transparent [ui.Image] out.
  static Future<ui.Image> cutoutImage(Uint8List bytes) async {
    if (!_ready) {
      await BackgroundRemover.instance.initializeOrt();
      _ready = true;
    }
    return BackgroundRemover.instance.removeBg(bytes);
  }

  /// Takes a media file name, returns the media file name of the cut-out PNG.
  static Future<String> remove(String mediaName) async {
    final store = StorageService.instance;
    final bytes = await File(store.media(mediaName)).readAsBytes();
    final out = await cutoutImage(bytes);
    final data = await out.toByteData(format: ui.ImageByteFormat.png);
    return store.saveBytes(data!.buffer.asUint8List(), 'png');
  }
}
