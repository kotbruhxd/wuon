
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wuon/editor.dart';

class MuonWelcomeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlertDialog(
        title: Center(child: Text("Welcome to wuon!")),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ElevatedButton(
                child: Text("Create New Project"),
                onPressed: () async {
                  final suc = await MuonEditor.createNewProject();
                  if(suc == true) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text("Open Project"),
                onPressed: () async {
                  final suc = await MuonEditor.openProject(context);
                  if(suc == true) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("About"),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationVersion: "0.0.4",
                applicationName: "wuon",
                applicationLegalese: "copyright (c) swadical 2021",
              );
            },
          ),
          OutlinedButton(
            child: Text("Quit"),
            onPressed: () {
              exit(0);
            },
          ),
        ],
      ),
    );
  }
}
