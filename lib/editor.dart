
import "dart:async";
import "dart:io";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:wuon/controllers/muonnote.dart";
import "package:wuon/controllers/muonproject.dart";
import "package:wuon/controllers/muonvoice.dart";
import "package:wuon/logic/japanese.dart";
import 'package:wuon/pianoroll/modules/notes.dart';
import 'package:wuon/pianoroll/modules/pitch.dart';
import 'package:wuon/pianoroll/modules/waila.dart';
import "package:wuon/pianoroll/pianoroll.dart";
import "package:wuon/serializable/settings.dart";
import "package:file_selector_platform_interface/file_selector_platform_interface.dart";
import 'package:wuon/widgets/dialogs/firsttimesetup.dart';
import 'package:wuon/widgets/dialogs/welcome.dart';
import 'package:wuon/widgets/overlay/appbar.dart';
import 'package:wuon/widgets/overlay/sidebar.dart';
import "package:path/path.dart" as p;
import 'package:synaps_flutter/synaps_flutter.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';
import 'package:wuon/logic/wavmix.dart';

final currentProject = MuonProjectController.defaultProject();

/// Shared single audio player — wfad's native code uses a global ma_context
/// that crashes when multiple players are created/destroyed.
AudioPlayer? _sharedPlayer;

class MuonEditor extends StatefulWidget {
  MuonEditor() : super();

  /// Shows the welcome screen via [showDialog]
  static void showWelcomeScreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext subContext) {
        return MuonWelcomeDialog();
      },
    );
  }

  /// Shows the first time setup screen via [showDialog]
  static void performFirstTimeSetup(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext subContext) {
        return MuonFirstTimeSetupDialog();
      },
    );
  }

  /// Opens a file selector dialog and prompts the user to open
  /// a project.json file
  static Future openProject(BuildContext context) {
    return FileSelectorPlatform.instance.openFile(
      confirmButtonText: "Open Project",
      acceptedTypeGroups: [XTypeGroup(
        label: "wuon Project Files",
        extensions: ["json"],
      )],
    )
    .then((value) {
      if(value != null) {
        final proj = MuonProjectController.loadFromFile(value.path);
        if(proj != null) {
          currentProject.updateWith(proj);
          return true;
        }
      }
    })
    .catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: new Text("internal error: " + err.toString()),
          duration: new Duration(seconds: 10),
        )
      );
      return null;
    }); // oh wow i am so naughty
  }

  /// Opens a file selector dialog and prompts the user to create
  /// a project.json file
  static Future createNewProject() {
    return FileSelectorPlatform.instance.getSavePath(
      confirmButtonText: "Create Project",
      acceptedTypeGroups: [XTypeGroup(
        label: "wuon Project Files",
        extensions: ["json"],
      )],
      suggestedName: "project.json",
    )
    .then((value) {
      if(value != null) {
        currentProject.updateWith(MuonProjectController.defaultProject());
        currentProject.projectDir = p.dirname(value);
        currentProject.projectFileName = p.basename(value);
        if(!currentProject.projectFileName.endsWith(".json")) {
          currentProject.projectFileName += ".json";
        }
        currentProject.save();

        return true;
      }
    })
    .catchError((err) {print("internal error: " + err.toString()); return null;}); // oh wow i am so naughty
  }

  /// Compiles all voices, and then plays audio from the playhead's
  /// current position
  /// 
  /// Will show snackbars on errors
  /// 
  static Future<void> playAudio(BuildContext context) async {
    if(currentProject.internalStatus != "idle") {return;}

    currentProject.internalStatus = "compiling";
    for(final voice in currentProject.voices) {
      await compileVoice(voice);
    }
    currentProject.internalStatus = "idle";

    // Mix all voices into a single WAV, then play with one shared AudioPlayer
    final mixedPath = mixVoiceWavs(currentProject);
    if (mixedPath.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text("No audio files to play"),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final playPos = Duration(
      milliseconds: currentProject.getLabelMillisecondOffset() + 
        (
          1000 * 
          (
            currentProject.playheadTime / 
            (currentProject.bpm / 60)
          )
        ).floor()
      );

    await _sharedPlayer?.unload();
    _sharedPlayer ??= AudioPlayer(id: 0);

    try {
      await _sharedPlayer!.load(AudioSource.fromFile(File(mixedPath)));
      await _sharedPlayer!.setPosition(playPos);
      await _sharedPlayer!.play();
      currentProject.internalStatus = "playing";
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text("Unable to play audio!"),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  static Future<void> compileVoice(MuonVoiceController voice) async {
    if(voice.hasChangedNoteData && voice.notes.isNotEmpty) {
      voice.hasChangedNoteData = false;
      try {
        await voice.makeLabels();
        await voice.runNeutrino();
      } catch (e) {
        print("[wuon] Compilation error for voice ${voice.modelName}: $e");
      }
    }
  }

  /// Compiles all voices
  /// 
  /// Will show snackbars on progress
  /// 
  static Future<void> compileVoiceInternalAll(BuildContext context) async {
    currentProject.internalStatus = "compiling";
    int voiceID = 0;
    for(final voice in currentProject.voices) {
      voiceID++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: new Text("Compiling voice " + voiceID.toString() + "..."),
          duration: new Duration(seconds: 2),
        )
      );
      await compileVoice(voice);
    }
    currentProject.internalStatus = "idle";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: new Text("Compilation complete!"),
        duration: new Duration(seconds: 2),
      )
    );
  }

  /// Stops any currently playing audio, if there is any.
  /// Otherwise, brings the playhead to the start of the project.
  static Future<void> stopAudio() async {
    await _sharedPlayer?.unload();
    if(currentProject.internalStatus == "playing") {
      currentProject.internalStatus = "idle";
    }
    else {
      currentProject.playheadTime = 0;
    }
  }

  /// Exports all voice WAVs to a user-selected directory.
  /// Compiles first if note data has changed.
  static Future<void> exportAllVoices(BuildContext context) async {
    if (currentProject.voices.isEmpty) return;

    if (currentProject.voices.any((v) => v.hasChangedNoteData)) {
      currentProject.internalStatus = "compiling";
      for (final voice in currentProject.voices) {
        await compileVoice(voice);
      }
      currentProject.internalStatus = "idle";
    }

    final dir = await FileSelectorPlatform.instance.getDirectoryPath(
      confirmButtonText: "Export",
    );
    if (dir == null) return;

    int exported = 0;
    for (final voice in currentProject.voices) {
      final wavPath = voice.project.getProjectFilePath("audio/" + voice.voiceFileName + ".wav");
      if (!File(wavPath).existsSync()) continue;

      final outName = voice.modelName.isNotEmpty
          ? "${voice.modelName}_${voice.voiceFileName}.wav"
          : "${voice.voiceFileName}.wav";
      await File(wavPath).copy("$dir/$outName");
      exported++;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exported $exported voice(s) to $dir"),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  _MuonEditorState createState() => _MuonEditorState();
}

class _MuonEditorState extends State<MuonEditor> {
  static bool _firstTimeRunning = true;

  void _onFirstRun(BuildContext context) {
    final settings = getMuonSettings();

    if(settings.neutrinoDir == "") {
      // no neutrino library, so let's perform first time set-up!
      Timer(Duration(milliseconds: 1),() {
        MuonEditor.performFirstTimeSetup(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    currentProject.setupPlaybackTimers();

    if(_firstTimeRunning) {
      _firstTimeRunning = false;
      _onFirstRun(context);
    }

    return Scaffold(
      appBar: MuonAppBar(),
      body: Column(
        children: [
          Rx(() => currentProject.internalStatus == "compiling"
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.amber.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text("Rendering...", style: TextStyle(fontSize: 13)),
                    Spacer(),
                    Text("compiling voices", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              )
            : SizedBox.shrink()),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: PianoRoll(
                    project: currentProject,
                    modules: [
                      PianoRollNotesModule(selectedNotes: currentProject.selectedNotes),
                      PianoRollPitchModule(),
                      PianoRollWAILAModule(),
                    ],
                    onKey: (pianoRoll,keyEvent) {
                      if(keyEvent.isControlPressed) {
                        if(keyEvent.isKeyPressed(LogicalKeyboardKey.keyS)) {
                          currentProject.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: new Text("Saved project!"),
                              duration: new Duration(seconds: 2),
                            )
                          );
                        }
                        else if(keyEvent.isKeyPressed(LogicalKeyboardKey.keyZ)) {
                          currentProject.undoAction();
                        }
                        else if(keyEvent.isKeyPressed(LogicalKeyboardKey.keyY)) {
                          currentProject.redoAction();
                        }
                      }

                      if(keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
                        if(currentProject.internalStatus == "playing") {
                          MuonEditor.stopAudio();
                        }
                        else {
                          MuonEditor.playAudio(context);
                        }
                      }
                    },
                  )
                ),
                MuonSidebar(),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
