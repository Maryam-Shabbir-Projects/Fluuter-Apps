import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Captures the RepaintBoundary behind [key] as a PNG [width] pixels wide.
  static Future<Uint8List> capture(GlobalKey key, {required double width}) async {
    final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: width / b.size.width);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  /// Opens the share sheet (choose "Save to gallery / Files").
  static Future<void> share(Uint8List png, String name) async {
    final safe = name.replaceAll(RegExp(r'[^\w\-]+'), '_');
    final f = File('${(await getTemporaryDirectory()).path}/$safe.png');
    await f.writeAsBytes(png);
    await Share.shareXFiles([XFile(f.path)]);
  }
}
