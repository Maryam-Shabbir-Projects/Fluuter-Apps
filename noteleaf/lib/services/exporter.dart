import 'dart:io';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';
import '../models/doc.dart';

/// Saves pages to the photo album as PNG images, or as one MP4 video (optionally with voice-over).
/// [from] and [to] are 1-based page numbers; [to] <= 0 means the last page.
/// With a voice-over and [sync] on, each page is shown for a share of the audio length
/// proportional to its word count (an estimate, not exact word timing).
class Exporter {
  static Future<String> run(Doc d,
      {required bool video, required bool hd, required double sec, required bool sync, required int from, required int to,
      required void Function(double) onProgress}) async {
    if (!await Gal.hasAccess(toAlbum: true) && !await Gal.requestAccess(toAlbum: true)) throw 'Photo access was denied';
    await GoogleFonts.pendingFonts();
    final n = d.pages.length, a = (from - 1).clamp(0, n - 1), b = ((to <= 0 ? n : to) - 1).clamp(a, n - 1), cnt = b - a + 1;
    if (!video) {
      for (var i = a; i <= b; i++) {
        final bytes = await (await d.render(i, 1)).toByteData(format: ui.ImageByteFormat.png);
        await Gal.putImageBytes(bytes!.buffer.asUint8List(), album: kAppName);
        onProgress((i - a + 1) / cnt);
      }
      return 'Saved $cnt page images to the album $kAppName.';
    }

    final sc = hd ? 1.0 : 2 / 3;
    final w = (d.px.width * sc / 2).round() * 2, h = (d.px.height * sc / 2).round() * 2; // even sizes for video
    final work = await Directory('${(await getTemporaryDirectory()).path}/render_${DateTime.now().millisecondsSinceEpoch}').create();
    final audio = d.audio;
    var durs = List<double>.filled(cnt, sec);
    if (audio != null && sync) {
      final len = await _audioSeconds(audio);
      if (len > 0) {
        final words = [for (var i = a; i <= b; i++) d.pages[i].words < 1 ? 1 : d.pages[i].words];
        final sum = words.fold<int>(0, (x, y) => x + y);
        durs = [for (final x in words) len * x / sum];
      }
    }
    try {
      for (var i = a; i <= b; i++) {
        final bytes = await (await d.render(i, w / d.px.width)).toByteData(format: ui.ImageByteFormat.png);
        await File('${work.path}/p${i - a}.png').writeAsBytes(bytes!.buffer.asUint8List());
        onProgress(0.7 * (i - a + 1) / cnt);
      }
      final list = StringBuffer();
      for (var k = 0; k < cnt; k++) {
        list..writeln("file 'p$k.png'")..writeln('duration ${durs[k].toStringAsFixed(3)}');
      }
      list.writeln("file 'p${cnt - 1}.png'"); // the concat format needs the last file repeated
      await File('${work.path}/list.txt').writeAsString(list.toString());
      final out = '${work.path}/out.mp4';
      String cmd(String vcodec) => '-y -f concat -safe 0 -i "${work.path}/list.txt" ${audio != null ? '-i "$audio" ' : ''}'
          '-vf "scale=$w:$h,format=yuv420p" -r 30 $vcodec ${audio != null ? '-c:a aac -b:a 160k -shortest ' : ''}-movflags +faststart "$out"';
      onProgress(0.75);
      var s = await FFmpegKit.execute(cmd('-c:v libx264 -preset veryfast -crf 23'));
      if (!ReturnCode.isSuccess(await s.getReturnCode())) s = await FFmpegKit.execute(cmd('-c:v mpeg4 -q:v 3')); // fallback encoder
      if (!ReturnCode.isSuccess(await s.getReturnCode())) throw 'Video encoding failed';
      await Gal.putVideo(out, album: kAppName);
      onProgress(1);
      final total = durs.fold<double>(0, (x, y) => x + y).round();
      return 'Saved a $total second video${audio != null ? ' with voice-over' : ''} to the album $kAppName.';
    } finally {
      work.delete(recursive: true);
    }
  }

  static Future<double> _audioSeconds(String path) async {
    final info = (await FFprobeKit.getMediaInformation(path)).getMediaInformation();
    return double.tryParse(await info?.getDuration() ?? '') ?? 0;
  }
}
