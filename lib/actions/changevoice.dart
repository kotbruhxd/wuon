part of 'base.dart';

class ChangeVoiceAction extends MuonAction {
  String get title => "Change voice";
  String get subtitle => "to $newVoiceModel";

  final MuonVoiceController voice;
  final String newVoiceModel;
  final String oldVoiceModel;

  ChangeVoiceAction(this.voice, this.newVoiceModel, this.oldVoiceModel);

  void perform() {
    voice.modelName = newVoiceModel;
  }

  void undo() {
    voice.modelName = oldVoiceModel;
  }

  void markVoiceModified() {
    voice.hasChangedNoteData = true;
  }
}
