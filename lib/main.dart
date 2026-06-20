import "dart:io";

import "package:flutter/material.dart";
import 'package:wuon/controllers/settings.dart';
import "package:wuon/licenses.dart";
import "package:wuon/editor.dart";
import 'package:synaps_flutter/synaps_flutter.dart';

import "package:window_size/window_size.dart";

final appSettings = MuonSettingsController().ctx();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("wuon");
    setWindowMinSize(Size(1280, 720));
  }

  addLicenses();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Rx(() => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "wuon",
      themeMode: appSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    ));
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MuonEditor()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F0FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.music_note, size: 64, color: Colors.purple),
            ),
            SizedBox(height: 24),
            Text("wuon", style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 2,
            )),
            SizedBox(height: 8),
            Text("singing synthesizer frontend", style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            )),
            SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: isDark ? Colors.white10 : Colors.purple.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
