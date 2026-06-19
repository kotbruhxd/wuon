part of 'base.dart';

class PasteNoteAction extends MuonAction {
  String get title => notes.length > 1 ? "Paste notes" : "Paste note";
  String get subtitle => "";

  final List<MuonNoteController> notes;

  PasteNoteAction(this.notes);

  void perform() {
    for(final note in notes) {
      note.voice.addNoteInternal(note);
    }
  }

  void undo() {
    for(final note in notes) {
      note.voice.notes.remove(note);
    }
  }

  void markVoiceModified() {
    for(final note in notes) {
      note.voice.hasChangedNoteData = true;
    }
  }
}
