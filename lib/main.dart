import "dart:io";

import "package:flutter/material.dart";
import 'package:wuon/controllers/settings.dart';
import "package:wuon/licenses.dart";
import "package:wuon/editor.dart";
import 'package:synaps_flutter/synaps_flutter.dart';

import "package:window_size/window_size.dart";

/// Main app settings
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
      home: MuonEditor(),
    ));
  }
}
