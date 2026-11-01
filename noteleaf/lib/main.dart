import 'package:flutter/material.dart';
import 'app.dart';
import 'services/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NoteLeafApp(seenWelcome: await Storage.hasSeen()));
}
