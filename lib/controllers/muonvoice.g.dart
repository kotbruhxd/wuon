// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muonvoice.dart';

// **************************************************************************
// ObservableGenerator
// **************************************************************************

class $MuonVoiceController extends MuonVoiceController
    with SynapsControllerInterface<MuonVoiceController> {
  @override
  final MuonVoiceController boxedValue;
  @override
  MuonProjectController get project {
    return super.project;
  }

  @override
  set project(MuonProjectController value) {
    super.project = value;
  }

  @override
  String get modelName {
    synapsMarkVariableRead(#modelName);
    return boxedValue.modelName;
  }

  @override
  set modelName(String value) {
    boxedValue.modelName = value;
    synapsMarkVariableDirty(#modelName, value);
  }

  @override
  bool get randomiseTiming {
    synapsMarkVariableRead(#randomiseTiming);
    return boxedValue.randomiseTiming;
  }

  @override
  set randomiseTiming(bool value) {
    boxedValue.randomiseTiming = value;
    synapsMarkVariableDirty(#randomiseTiming, value);
  }

  @override
  int get tune {
    synapsMarkVariableRead(#tune);
    return boxedValue.tune;
  }

  @override
  set tune(int value) {
    boxedValue.tune = value;
    synapsMarkVariableDirty(#tune, value);
  }

  @override
  int get transpose {
    synapsMarkVariableRead(#transpose);
    return boxedValue.transpose;
  }

  @override
  set transpose(int value) {
    boxedValue.transpose = value;
    synapsMarkVariableDirty(#transpose, value);
  }

  late SynapsList<MuonNoteController> _proxy_notes;
  @override
  SynapsList<MuonNoteController> get notes {
    synapsMarkVariableRead(#notes);
    return _proxy_notes;
  }

  @override
  set notes(List<MuonNoteController> value) {
    _proxy_notes = value.ctx();
    boxedValue.notes = _proxy_notes;
    synapsMarkVariableDirty(#notes, value);
  }

  @override
  bool get hasChangedNoteData {
    return super.hasChangedNoteData;
  }

  @override
  set hasChangedNoteData(bool value) {
    super.hasChangedNoteData = value;
  }

  @override
  AudioPlayer? get audioPlayer {
    return super.audioPlayer;
  }

  @override
  set audioPlayer(AudioPlayer? value) {
    super.audioPlayer = value;
  }

  @override
  int get audioPlayerDuration {
    return super.audioPlayerDuration;
  }

  @override
  set audioPlayerDuration(int value) {
    super.audioPlayerDuration = value;
  }

  @override
  dynamic get color {
    return super.color;
  }

  @override
  String get voiceFileName {
    return super.voiceFileName;
  }

  @override
  MusicXML exportVoiceToMusicXML() {
    return super.exportVoiceToMusicXML();
  }

  @override
  void sortNotesByTime() {
    return super.sortNotesByTime();
  }

  @override
  void addNote(MuonNoteController note) {
    return super.addNote(note);
  }

  @override
  void addNoteInternal(MuonNoteController note) {
    return super.addNoteInternal(note);
  }

  @override
  Future<void> makeLabels() async {
    return await super.makeLabels();
  }

  @override
  Future<void> runNeutrino() async {
    return await super.runNeutrino();
  }

  @override
  Future<AudioPlayer?> getAudioPlayer([Duration? playPos]) async {
    return await super.getAudioPlayer(playPos);
  }

  @override
  MuonVoice toSerializable([MuonProject? project]) {
    return super.toSerializable(project);
  }

  $MuonVoiceController(this.boxedValue) : super() {
    _proxy_notes = boxedValue.notes.ctx();
  }
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

extension MuonVoiceControllerExtension on MuonVoiceController {
  $MuonVoiceController asController() {
    if (this is $MuonVoiceController) return this as $MuonVoiceController;
    return $MuonVoiceController(this);
  }

  $MuonVoiceController ctx() => asController();
  MuonVoiceController get boxedValue => this;
}
