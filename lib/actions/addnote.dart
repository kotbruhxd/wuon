part of 'base.dart';

class AddNoteAction extends MuonAction {
  String get title => "Add note";
  String get subtitle => "";

  final MuonNoteController note;

  AddNoteAction(this.note);

  void perform() {
    note.voice.addNoteInternal(note);
  }

  void undo() {
    note.voice.notes.remove(note);
  }

  void markVoiceModified() {
    note.voice.hasChangedNoteData = true;
  }
}
