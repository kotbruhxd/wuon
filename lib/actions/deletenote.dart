part of 'base.dart';

class DeleteNoteAction extends MuonAction {
  String get title => notes.length > 1 ? "Delete notes" : "Delete note";
  String get subtitle => "";

  final List<MuonNoteController> notes;

  DeleteNoteAction(this.notes);

  void perform() {
    for(final note in notes) {
      note.voice.notes.remove(note);
    }
  }

  void undo() {
    for(final note in notes) {
      note.voice.addNoteInternal(note);
    }
  }

  void markVoiceModified() {
    for(final note in notes) {
      note.voice.hasChangedNoteData = true;
    }
  }
}
