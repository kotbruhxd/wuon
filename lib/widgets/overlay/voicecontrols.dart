import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wuon/actions/base.dart';
import "package:synaps_flutter/synaps_flutter.dart";
import 'package:wuon/controllers/muonvoice.dart';
import 'package:wuon/editor.dart';
import 'package:wuon/logic/helpers.dart';

class MuonVoiceControls extends StatelessWidget {
  const MuonVoiceControls({
    Key? key,
    required this.voice,
  }) : super(key: key);

  final MuonVoiceController voice;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            padding: EdgeInsets.only(left: 15),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: voice.color as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.7),
                        blurRadius: 2,
                        spreadRadius: 2,
                      ),
                    ]
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Rx(() => Text(
                    "Voice " + (currentProject.voices.indexOf(voice) + 1).toString() + " (" + voice.modelName + ")",
                  ))
                ),
                Expanded(
                  child: Container(),
                ),
                Rx(() => IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  disabledColor: Colors.green.withValues(alpha: 0.9),
                  tooltip: "Select voice",
                  onPressed: currentProject.currentVoiceID == currentProject.voices.indexOf(voice) ? null : () {
                    currentProject.currentVoiceID = currentProject.voices.indexOf(voice);
                  },
                )),
                PopupMenuButton(
                  icon: const Icon(Icons.speaker_notes),
                  tooltip: "Change voice model",
                  onSelected: (String result) {
                    final oldModel = voice.modelName;
                    voice.modelName = result;

                    final action = ChangeVoiceAction(voice, result, oldModel);
                    currentProject.addAction(action);
                  },
                  itemBuilder: (BuildContext context) {
                    final List<PopupMenuItem<String>> items = [];

                    final models = MuonHelpers.getAllVoiceModels();

                    for(final modelName in models) {
                      items.add(
                        PopupMenuItem(
                          value: modelName,
                          child: Text(modelName),
                        ),
                      );
                    }

                    return items;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: "Delete voice",
                  onPressed: () {
                    if(voice.audioPlayer != null) {
                      voice.audioPlayer?.dispose();
                      voice.audioPlayer = null;
                    }
                    final currentID = voice.project.voices.indexOf(voice);
                    if(voice.project.currentVoiceID >= currentID) {
                      voice.project.currentVoiceID--;
                      voice.project.currentVoiceID = max(0, voice.project.currentVoiceID);
                    }
                    currentProject.voices.remove(voice);
                    final action = RemoveVoiceAction(voice);
                    currentProject.addAction(action);
                  },
                ),
              ],
            ),
          ),
          // tuning controls
          Rx(() => Container(
            padding: EdgeInsets.only(left: 25, right: 10, bottom: 6),
            child: Row(
              children: [
                Text("Tune", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                SizedBox(width: 4),
                _TuningButton(icon: Icons.remove, onTap: () => voice.tune = max(-12, voice.tune - 1)),
                Text("${voice.tune >= 0 ? "+" : ""}${voice.tune}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                _TuningButton(icon: Icons.add, onTap: () => voice.tune = min(12, voice.tune + 1)),
                SizedBox(width: 12),
                Text("Transpose", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                SizedBox(width: 4),
                _TuningButton(icon: Icons.remove, onTap: () => voice.transpose = max(-12, voice.transpose - 1)),
                Text("${voice.transpose >= 0 ? "+" : ""}${voice.transpose}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                _TuningButton(icon: Icons.add, onTap: () => voice.transpose = min(12, voice.transpose + 1)),
                Spacer(),
                Icon(Icons.music_note, size: 14, color: Colors.grey[400]),
              ],
            ),
          )),
        ],
      ),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ]
      ),
    );
  }
}

class _TuningButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TuningButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Icon(icon, size: 14),
        ),
      ),
    );
  }
}
