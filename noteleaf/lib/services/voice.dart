import 'dart:async';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Voice typing: speech to text that keeps listening until stopped.
class Dictation {
  final _s = SpeechToText();
  bool want = false;
  String _locale = 'en_US';
  void Function(String)? _onText;

  Future<List<LocaleName>> init() async {
    final ok = await _s.initialize(onStatus: (st) {
      if (want && (st == 'done' || st == 'notListening')) {
        Future.delayed(const Duration(milliseconds: 300), _listen);
      }
    });
    return ok ? await _s.locales() : [];
  }

  void _listen() {
    if (!want || _s.isListening) return;
    _s.listen(
      localeId: _locale,
      onResult: (r) {
        if (r.finalResult && r.recognizedWords.isNotEmpty) _onText?.call(r.recognizedWords);
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 6),
      listenOptions: SpeechListenOptions(partialResults: false, listenMode: ListenMode.dictation),
    );
  }

  void start(String locale, void Function(String) onText) {
    _locale = locale;
    _onText = onText;
    want = true;
    _listen();
  }

  Future<void> stop() async {
    want = false;
    await _s.stop();
  }
}

/// Records a voice-over to an .m4a file.
class VoiceRecorder {
  final _r = AudioRecorder();

  Future<bool> start(String path) async {
    if (!await _r.hasPermission()) return false;
    await _r.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    return true;
  }

  Future<String?> stop() => _r.stop();
}
