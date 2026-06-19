part of 'base.dart';

class AddVoiceAction extends MuonAction {
  String get title => "Add voice";
  String get subtitle => "";

  final MuonVoiceController voice;

  AddVoiceAction(this.voice);

  void perform() {
    voice.project.addVoiceInternal(voice);
  }

  void undo() {
    final currentID = voice.project.voices.indexOf(voice);
    if(voice.project.currentVoiceID >= currentID) {
      voice.project.currentVoiceID--;
      voice.project.currentVoiceID = max(0, voice.project.currentVoiceID);
    }
    if(voice.audioPlayer != null) {
      voice.audioPlayer?.dispose();
      voice.audioPlayer = null;
    }
    voice.project.voices.remove(voice);
  }
}
