part of 'base.dart';

class SetNoteTuneAction extends MuonAction {
  String get title => "Set note tune";
  String get subtitle => "${note.note}${note.octave}: $newTune st";

  final MuonNoteController note;
  final int newTune;
  final int oldTune;

  SetNoteTuneAction(this.note, this.newTune, this.oldTune);

  void perform() {
    note.tune = newTune;
  }

  void undo() {
    note.tune = oldTune;
  }

  void markVoiceModified() {
    note.voice.hasChangedNoteData = true;
  }
}
