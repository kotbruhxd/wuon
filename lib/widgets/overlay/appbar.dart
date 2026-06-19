import 'dart:math';

import 'package:flutter/material.dart';
import "package:synaps_flutter/synaps_flutter.dart";
import 'package:wuon/editor.dart';
import 'package:wuon/main.dart';

class MuonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MuonAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
            title: Text("wuon"),
      actions: [
        IconButton(
          icon: const Icon(Icons.exposure_plus_1),
          tooltip: "Add subdivision",
          onPressed: () {
            currentProject.setSubdivision(currentProject.currentSubdivision + 1);
          },
        ),
        IconButton(
          icon: const Icon(Icons.exposure_minus_1),
          tooltip: "Subtract subdivision",
          onPressed: () {
            currentProject.setSubdivision(max(1,currentProject.currentSubdivision - 1));
          },
        ),
        SizedBox(width: 40,),
        Rx(() => IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: "Play",
          color: currentProject.internalStatus == "compiling" ? 
            Colors.yellow : 
              currentProject.internalStatus == "playing" ?
                Colors.green :
                Colors.white,
          onPressed: () {
            MuonEditor.playAudio(context);
          },
        )),
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: "Stop",
          onPressed: () {
            MuonEditor.stopAudio();
          },
        ),
        SizedBox(width: 20,),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: "More",
          onSelected: (value) async {
            final ctx = context;
            switch (value) {
              case "labels":
                for (final voice in currentProject.voices) {
                  voice.makeLabels();
                }
              case "neutrino":
                for (final voice in currentProject.voices) {
                  voice.runNeutrino();
                }
              case "export":
                await MuonEditor.exportAllVoices(ctx);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: "labels", child: Text("Generate labels only")),
            const PopupMenuItem(value: "neutrino", child: Text("Generate neutrino only")),
            const PopupMenuDivider(),
            const PopupMenuItem(value: "export", child: ListTile(
              leading: Icon(Icons.file_download),
              title: Text("Export WAV..."),
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
        SizedBox(width: 40,),
        Rx(() => IconButton(
            icon: appSettings.darkMode ? const Icon(Icons.lightbulb) : const Icon(Icons.lightbulb_outline),
            tooltip: appSettings.darkMode ? "Lights on" : "Lights out",
            onPressed: () {
              appSettings.darkMode = !appSettings.darkMode;
            },
          ),
        ),
        SizedBox(width: 40,),
        IconButton(
          icon: const Icon(Icons.save),
          tooltip: "Save",
          onPressed: () {
            currentProject.save();
          },
        ),
        IconButton(
          icon: const Icon(Icons.folder),
          tooltip: "Load",
          onPressed: () {
            MuonEditor.openProject(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.create),
          tooltip: "New project",
          onPressed: () {
            MuonEditor.createNewProject();
          },
        ),
        SizedBox(width: 20,),
      ],
    );
  }
}
