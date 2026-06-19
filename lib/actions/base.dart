import 'dart:math';

import 'package:wuon/controllers/muonnote.dart';
import 'package:wuon/controllers/muonvoice.dart';

part 'addnote.dart';
part 'addvoice.dart';
part 'changevoice.dart';
part 'cutnote.dart';
part 'deletenote.dart';
part 'movenote.dart';
part 'pastenote.dart';
part 'removevoice.dart';
part 'renamenote.dart';
part 'retimenote.dart';

sealed class MuonAction {
  String get title;
  String get subtitle;
  void perform();
  void undo();
  void markVoiceModified() {}
}
