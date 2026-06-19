part of 'base.dart';

class RenameNoteAction extends MuonAction {
  String get title => newLyrics.length > 1 ? "Rename ${newLyrics.length} note lyrics" : "Rename note lyric";
  String get subtitle => "to $textInput";

  final Map<MuonNoteController, String> newLyrics;
  final Map<MuonNoteController, String> oldLyrics;
  final String textInput;

  RenameNoteAction(this.newLyrics, this.oldLyrics, this.textInput);

  void perform() {
    for(final note in newLyrics.keys) {
      note.lyric = newLyrics[note]!;
    }
  }

  void undo() {
    for(final note in oldLyrics.keys) {
      note.lyric = oldLyrics[note]!;
    }
  }

  void markVoiceModified() {
    for(final note in newLyrics.keys) {
      note.voice.hasChangedNoteData = true;
    }
  }
}
