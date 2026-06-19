import "dart:convert";
import "dart:io";

import "package:json_annotation/json_annotation.dart";

part "settings.g.dart";

String _settingsPath() {
  final home = Platform.environment["HOME"] ?? ".";
  return "$home/.config/wuon/settings.json";
}

@JsonSerializable()
class MuonSettings {
  MuonSettings();

  bool darkMode = false;
  String neutrinoDir = "";

  factory MuonSettings.fromJson(Map<String, dynamic> json) => _$MuonSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$MuonSettingsToJson(this);

  static MuonSettings? loadFromFile([String settingsFile = ""]) {
    final path = settingsFile.isEmpty ? _settingsPath() : settingsFile;
    final file = File(path);
    if (!file.existsSync()) return null;

    final fileContents = file.readAsStringSync();
    final jsonData = jsonDecode(fileContents);
    return MuonSettings.fromJson(jsonData as Map<String, dynamic>);
  }

  void save([String settingsFile = ""]) {
    final path = settingsFile.isEmpty ? _settingsPath() : settingsFile;
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(toJson()));
  }
}

MuonSettings getMuonSettings() {
  return MuonSettings.loadFromFile() ?? MuonSettings();
}
