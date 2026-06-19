// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muonproject.dart';

// **************************************************************************
// ObservableGenerator
// **************************************************************************

class $MuonProjectController extends MuonProjectController
    with SynapsControllerInterface<MuonProjectController> {
  @override
  final MuonProjectController boxedValue;
  @override
  String get projectDir {
    synapsMarkVariableRead(#projectDir);
    return boxedValue.projectDir;
  }

  @override
  set projectDir(String value) {
    boxedValue.projectDir = value;
    synapsMarkVariableDirty(#projectDir, value);
  }

  @override
  String get projectFileName {
    synapsMarkVariableRead(#projectFileName);
    return boxedValue.projectFileName;
  }

  @override
  set projectFileName(String value) {
    boxedValue.projectFileName = value;
    synapsMarkVariableDirty(#projectFileName, value);
  }

  @override
  double get bpm {
    synapsMarkVariableRead(#bpm);
    return boxedValue.bpm;
  }

  @override
  set bpm(double value) {
    boxedValue.bpm = value;
    synapsMarkVariableDirty(#bpm, value);
  }

  @override
  int get timeUnitsPerBeat {
    synapsMarkVariableRead(#timeUnitsPerBeat);
    return boxedValue.timeUnitsPerBeat;
  }

  @override
  set timeUnitsPerBeat(int value) {
    boxedValue.timeUnitsPerBeat = value;
    synapsMarkVariableDirty(#timeUnitsPerBeat, value);
  }

  @override
  int get beatsPerMeasure {
    synapsMarkVariableRead(#beatsPerMeasure);
    return boxedValue.beatsPerMeasure;
  }

  @override
  set beatsPerMeasure(int value) {
    boxedValue.beatsPerMeasure = value;
    synapsMarkVariableDirty(#beatsPerMeasure, value);
  }

  @override
  int get beatValue {
    synapsMarkVariableRead(#beatValue);
    return boxedValue.beatValue;
  }

  @override
  set beatValue(int value) {
    boxedValue.beatValue = value;
    synapsMarkVariableDirty(#beatValue, value);
  }

  late SynapsList<MuonVoiceController> _proxy_voices;
  @override
  SynapsList<MuonVoiceController> get voices {
    synapsMarkVariableRead(#voices);
    return _proxy_voices;
  }

  @override
  set voices(List<MuonVoiceController> value) {
    _proxy_voices = value.ctx();
    boxedValue.voices = _proxy_voices;
    synapsMarkVariableDirty(#voices, value);
  }

  @override
  int get currentVoiceID {
    synapsMarkVariableRead(#currentVoiceID);
    return boxedValue.currentVoiceID;
  }

  @override
  set currentVoiceID(int value) {
    boxedValue.currentVoiceID = value;
    synapsMarkVariableDirty(#currentVoiceID, value);
  }

  late SynapsMap<MuonNoteController, bool> _proxy_selectedNotes;
  @override
  SynapsMap<MuonNoteController, bool> get selectedNotes {
    synapsMarkVariableRead(#selectedNotes);
    return _proxy_selectedNotes;
  }

  @override
  double get playheadTime {
    synapsMarkVariableRead(#playheadTime);
    return boxedValue.playheadTime;
  }

  @override
  set playheadTime(double value) {
    boxedValue.playheadTime = value;
    synapsMarkVariableDirty(#playheadTime, value);
  }

  @override
  List<MuonNote> get copiedNotes {
    return super.copiedNotes;
  }

  @override
  set copiedNotes(List<MuonNote> value) {
    super.copiedNotes = value;
  }

  @override
  List<MuonVoiceController> get copiedNotesVoices {
    return super.copiedNotesVoices;
  }

  @override
  set copiedNotesVoices(List<MuonVoiceController> value) {
    super.copiedNotesVoices = value;
  }

  @override
  String get internalStatus {
    synapsMarkVariableRead(#internalStatus);
    return boxedValue.internalStatus;
  }

  @override
  set internalStatus(String value) {
    boxedValue.internalStatus = value;
    synapsMarkVariableDirty(#internalStatus, value);
  }

  @override
  int get currentSubdivision {
    return super.currentSubdivision;
  }

  @override
  set currentSubdivision(int value) {
    super.currentSubdivision = value;
  }

  late SynapsList<MuonAction> _proxy_actions;
  @override
  SynapsList<MuonAction> get actions {
    synapsMarkVariableRead(#actions);
    return _proxy_actions;
  }

  @override
  set actions(List<MuonAction> value) {
    _proxy_actions = value.ctx();
    boxedValue.actions = _proxy_actions;
    synapsMarkVariableDirty(#actions, value);
  }

  @override
  int get nextActionPos {
    synapsMarkVariableRead(#nextActionPos);
    return boxedValue.nextActionPos;
  }

  @override
  set nextActionPos(int value) {
    boxedValue.nextActionPos = value;
    synapsMarkVariableDirty(#nextActionPos, value);
  }

  @override
  Timer? get playbackTimer {
    return super.playbackTimer;
  }

  @override
  set playbackTimer(Timer? value) {
    super.playbackTimer = value;
  }

  @override
  String get projectFileNameNoExt {
    return super.projectFileNameNoExt;
  }

  @override
  String get projectFileNameNoSpacesNoExt {
    return super.projectFileNameNoSpacesNoExt;
  }

  @override
  int get timeUnitsPerSubdivision {
    return super.timeUnitsPerSubdivision;
  }

  @override
  void dispose() {
    return super.dispose();
  }

  @override
  void addAction(MuonAction action) {
    return super.addAction(action);
  }

  @override
  void undoAction() {
    return super.undoAction();
  }

  @override
  void redoAction() {
    return super.redoAction();
  }

  @override
  void undoUntilIndex(int index) {
    return super.undoUntilIndex(index);
  }

  @override
  void undoUntilAction(MuonAction action) {
    return super.undoUntilAction(action);
  }

  @override
  void redoUntilIndex(int index) {
    return super.redoUntilIndex(index);
  }

  @override
  void redoUntilAction(MuonAction action) {
    return super.redoUntilAction(action);
  }

  @override
  void markAllVoicesAsChanged() {
    return super.markAllVoicesAsChanged();
  }

  @override
  String getProjectFilePath(String filePath) {
    return super.getProjectFilePath(filePath);
  }

  @override
  String getQuotedProjectFilePath(String filePath) {
    return super.getQuotedProjectFilePath(filePath);
  }

  @override
  void addVoiceInternal(MuonVoiceController voice) {
    return super.addVoiceInternal(voice);
  }

  @override
  void addVoice(MuonVoiceController voice) {
    return super.addVoice(voice);
  }

  @override
  int getLabelMillisecondOffset() {
    return super.getLabelMillisecondOffset();
  }

  @override
  void updateWith(MuonProjectController controller) {
    return super.updateWith(controller);
  }

  @override
  void setupPlaybackTimers() {
    return super.setupPlaybackTimers();
  }

  @override
  void setSubdivision(int subdivision) {
    return super.setSubdivision(subdivision);
  }

  @override
  void factorTimeUnitsPerBeat() {
    return super.factorTimeUnitsPerBeat();
  }

  @override
  void setTimeUnitsPerBeat(int newTimeUnitsPerBeat) {
    return super.setTimeUnitsPerBeat(newTimeUnitsPerBeat);
  }

  @override
  bool importVoiceFromMIDIFile(String midiFilePath, bool importTimeMetadata) {
    return super.importVoiceFromMIDIFile(midiFilePath, importTimeMetadata);
  }

  @override
  void importVoiceFromMusicXML(MusicXML musicXML, bool importTimeMetadata) {
    return super.importVoiceFromMusicXML(musicXML, importTimeMetadata);
  }

  @override
  MusicXML exportVoiceToMusicXML(MuonVoiceController voice) {
    return super.exportVoiceToMusicXML(voice);
  }

  @override
  void save() {
    return super.save();
  }

  @override
  MuonProject toSerializable() {
    return super.toSerializable();
  }

  $MuonProjectController(this.boxedValue) : super() {
    _proxy_voices = boxedValue.voices.ctx();
    _proxy_selectedNotes = boxedValue.selectedNotes.ctx();
    _proxy_actions = boxedValue.actions.ctx();
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

extension MuonProjectControllerExtension on MuonProjectController {
  $MuonProjectController asController() {
    if (this is $MuonProjectController) return this as $MuonProjectController;
    return $MuonProjectController(this);
  }

  $MuonProjectController ctx() => asController();
  MuonProjectController get boxedValue => this;
}
