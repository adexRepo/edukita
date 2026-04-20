import 'package:edukita/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize bitsdojo_window for custom window controls
  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
    appWindow.alignment = Alignment.center;
    appWindow.size = initialSize;
    appWindow.minSize = initialSize;
    appWindow.show();
  });

  runApp(const EdukitaApp());
}
