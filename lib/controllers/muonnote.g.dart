// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muonnote.dart';

// **************************************************************************
// ObservableGenerator
// **************************************************************************

class $MuonNoteController extends MuonNoteController
    with SynapsControllerInterface<MuonNoteController> {
  @override
  final MuonNoteController boxedValue;
  @override
  MuonVoiceController get voice {
    return super.voice;
  }

  @override
  set voice(MuonVoiceController value) {
    super.voice = value;
  }

  @override
  String get note {
    synapsMarkVariableRead(#note);
    return boxedValue.note;
  }

  @override
  set note(String value) {
    boxedValue.note = value;
    synapsMarkVariableDirty(#note, value);
  }

  @override
  int get octave {
    synapsMarkVariableRead(#octave);
    return boxedValue.octave;
  }

  @override
  set octave(int value) {
    boxedValue.octave = value;
    synapsMarkVariableDirty(#octave, value);
  }

  @override
  String get lyric {
    synapsMarkVariableRead(#lyric);
    return boxedValue.lyric;
  }

  @override
  set lyric(String value) {
    boxedValue.lyric = value;
    synapsMarkVariableDirty(#lyric, value);
  }

  @override
  int get startAtTime {
    synapsMarkVariableRead(#startAtTime);
    return boxedValue.startAtTime;
  }

  @override
  set startAtTime(int value) {
    boxedValue.startAtTime = value;
    synapsMarkVariableDirty(#startAtTime, value);
  }

  @override
  int get duration {
    synapsMarkVariableRead(#duration);
    return boxedValue.duration;
  }

  @override
  set duration(int value) {
    boxedValue.duration = value;
    synapsMarkVariableDirty(#duration, value);
  }

  @override
  void addSemitones(int deltaSemitones) {
    return super.addSemitones(deltaSemitones);
  }

  @override
  int toAbsoluteSemitones() {
    return super.toAbsoluteSemitones();
  }

  @override
  MuonNote toSerializable() {
    return super.toSerializable();
  }

  $MuonNoteController(this.boxedValue) : super();
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (identical(other, boxedValue)) {
      return true;
    }
    if ((other is SynapsControllerInterface) &&
        identical(other.boxedValue, boxedValue)) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => boxedValue.hashCode;
}

extension MuonNoteControllerExtension on MuonNoteController {
  $MuonNoteController asController() {
    if (this is $MuonNoteController) return this as $MuonNoteController;
    return $MuonNoteController(this);
  }

  $MuonNoteController ctx() => asController();
  MuonNoteController get boxedValue => this;
}
