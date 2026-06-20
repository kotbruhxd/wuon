import "dart:convert";
import "dart:io";

import "package:json_annotation/json_annotation.dart";
import "package:path/path.dart" as p;

part "muon.g.dart";

@JsonSerializable()
class MuonNote {
  MuonNote();

  late String note;
  late int octave;
  late String lyric;

  // timing
  late int startAtTime;
  late int duration;

  // per-note tuning (semitones, -12 to +12)
  int tune = 0;

  // pitch envelope: list of (offset from note start in ticks, cents) pairs
  List<PitchPoint> pitchPoints = [];

  // vibrato
  bool vibratoEnabled = false;
  double vibratoDepth = 25;
  double vibratoFrequency = 5.5;
  double vibratoAttack = 0.1;

  factory MuonNote.fromJson(Map<String, dynamic> json) => _$MuonNoteFromJson(json);
  Map<String, dynamic> toJson() => _$MuonNoteToJson(this);
}

@JsonSerializable()
class PitchPoint {
  PitchPoint(this.offset, this.cents);

  /// Offset from note start in project time units
  late int offset;

  /// Pitch offset in cents (100 = 1 semitone)
  late double cents;

  factory PitchPoint.fromJson(Map<String, dynamic> json) => _$PitchPointFromJson(json);
  Map<String, dynamic> toJson() => _$PitchPointToJson(this);
}

@JsonSerializable()
class MuonVoice {
  MuonVoice();

  @JsonKey(includeFromJson: false, includeToJson: false)
  late MuonProject project;

  // voice metadata
  late String modelName;
  bool randomiseTiming = false;

  // tuning (semitones)
  int tune = 0;
  int transpose = 0;

  // notes
  List<MuonNote> notes = [];

  // synthesised data
  // TODO: F0, Aperiodicity, Spectral Envelope

  factory MuonVoice.fromJson(Map<String, dynamic> json) => _$MuonVoiceFromJson(json);
  Map<String, dynamic> toJson() => _$MuonVoiceToJson(this);
}

@JsonSerializable()
class MuonProject {
  MuonProject();

  // project metadata
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String projectDir;

  // project metadata
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String projectFileName;

  // tempo
  double bpm = 120;
  int timeUnitsPerBeat = 1;

  // time signature
  int beatsPerMeasure = 4;
  int beatValue = 4;

  List<MuonVoice> voices = [];

  factory MuonProject.fromJson(Map<String, dynamic> json) => _$MuonProjectFromJson(json);
  Map<String, dynamic> toJson() => _$MuonProjectToJson(this);

  static MuonProject? loadFromFile(String projectFile) {
    if(File(projectFile).existsSync()) {
      final file = new File(projectFile);

      if(file.existsSync()) {
        var fileContents = file.readAsStringSync();

        final jsonData = jsonDecode(fileContents);
        MuonProject project = MuonProject.fromJson(jsonData as Map<String, dynamic>);

        for(final voice in project.voices) {
          voice.project = project;
        }

        project.projectDir = p.dirname(projectFile);
        project.projectFileName = p.basename(projectFile);

        return project;
      }
    }

    return null;
  }

  static MuonProject? loadFromDir(String projectDir,String projectFileName) {
    if(Directory(projectDir).existsSync()) {
      return MuonProject.loadFromFile(projectDir + "/" + projectFileName);
    }

    return null;
  }

  void save() {
    if(!Directory(projectDir).existsSync()) {
      Directory(projectDir).createSync();
    }

    final jsonContents = this.toJson();
    String fileContents = jsonEncode(jsonContents);

    final file = new File(projectDir + "/" + projectFileName);
    file.writeAsStringSync(fileContents);
  }
}
