part of 'base.dart';

class RemoveVoiceAction extends MuonAction {
  String get title => "Remove voice";
  String get subtitle => "";

  final MuonVoiceController voice;

  RemoveVoiceAction(this.voice);

  void perform() {
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

  void undo() {
    voice.project.addVoiceInternal(voice);
  }
}
