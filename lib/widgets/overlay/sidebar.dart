import 'package:flutter/material.dart';
import 'package:wuon/widgets/overlay/actionsmenu.dart';
import 'package:wuon/widgets/overlay/projectmetadatamenu.dart';
import 'package:wuon/widgets/overlay/voicesmenu.dart';

class MuonSidebar extends StatelessWidget {
  const MuonSidebar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MuonProjectMetadataMenu(),
          const SizedBox(height: 10),
          Expanded(
            child: MuonVoicesMenu(),
          ),
          SizedBox(
            height: 150,
            child: MuonActionsMenu(),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
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
