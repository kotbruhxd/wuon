import "package:synaps_flutter/synaps_flutter.dart";
import "package:wuon/controllers/muonvoice.dart";
import "package:wuon/serializable/muon.dart";

part "muonnote.g.dart";

@Controller()
class MuonNoteController with WeakEqualityController {
  late MuonVoiceController voice;

  /// The alphabetical value of this note
  /// `/[A-G]#?/`
  @Observable()
  String note = "C";

  /// The octave of this note
  @Observable()
  int octave = 4;

  /// Any lyrics attached to this note
  /// (can be an empty string!)
  @Observable()
  String lyric = "";

  /// The time at which this note starts
  @Observable()
  int startAtTime = 0;

  /// The duration of this note
  @Observable()
  int duration = 0;

  /// Per-note pitch bend in semitones (-12 to +12)
  @Observable()
  int tune = 0;

  /// Pitch envelope control points
  List<PitchPoint> pitchPoints = [];

  /// Vibrato
  bool vibratoEnabled = false;
  double vibratoDepth = 25;
  double vibratoFrequency = 5.5;
  double vibratoAttack = 0.1;

  /// Adds `deltaSemitones` to this note
  /// 
  /// e.g. if this was a `C4`, adding `2` semitones gives you `D4`,
  /// and adding `-2` semitones gives you `A#3`
  void addSemitones(int deltaSemitones) {
    final midiNotes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"];

    final currentNoteID = midiNotes.indexOf(this.note);
    final deltaOctave = ((deltaSemitones + currentNoteID) / 12).floor();
    final fixedDeltaSemitones = deltaSemitones - deltaOctave * 12;
    
    note = midiNotes[currentNoteID + fixedDeltaSemitones];
    octave = octave + deltaOctave;
  }

  /// Returns the number of semitones this note is above C0.
  int toAbsoluteSemitones() {
    const midiNotes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"];

    final currentNoteID = midiNotes.indexOf(note);
    
    return octave * 12 + currentNoteID;
  }

  MuonNote toSerializable() {
    final out = MuonNote();
    out.note = this.note;
    out.octave = this.octave;
    out.lyric = this.lyric;
    out.startAtTime = this.startAtTime;
    out.duration = this.duration;
    out.tune = this.tune;
    out.pitchPoints = this.pitchPoints;
    out.vibratoEnabled = this.vibratoEnabled;
    out.vibratoDepth = this.vibratoDepth;
    out.vibratoFrequency = this.vibratoFrequency;
    out.vibratoAttack = this.vibratoAttack;
    return out;
  }

  static MuonNoteController fromSerializable(MuonNote obj) {
    final out = MuonNoteController().ctx();
    out.note = obj.note;
    out.octave = obj.octave;
    out.lyric = obj.lyric;
    out.startAtTime = obj.startAtTime;
    out.duration = obj.duration;
    out.tune = obj.tune;
    out.pitchPoints = obj.pitchPoints;
    out.vibratoEnabled = obj.vibratoEnabled;
    out.vibratoDepth = obj.vibratoDepth;
    out.vibratoFrequency = obj.vibratoFrequency;
    out.vibratoAttack = obj.vibratoAttack;
    return out;
  }
}
