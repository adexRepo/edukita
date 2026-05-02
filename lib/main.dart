import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:edukita/core/router/app_router.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

class EdukitaApp extends StatefulWidget {
  const EdukitaApp({super.key});

  @override
  State<EdukitaApp> createState() => _EdukitaAppState();
}

class _EdukitaAppState extends State<EdukitaApp> {
  @override
  void initState() {
    super.initState();
    setupLocator();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scrollBehavior: ScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
