import 'package:flutter/material.dart';
import 'package:wuon/widgets/overlay/actionsmenu.dart';
import 'package:wuon/widgets/overlay/projectmetadatamenu.dart';
import 'package:wuon/widgets/overlay/voicesmenu.dart';

class MuonSidebar extends StatefulWidget {
  const MuonSidebar({Key? key}) : super(key: key);

  @override
  State<MuonSidebar> createState() => _MuonSidebarState();
}

class _MuonSidebarState extends State<MuonSidebar> {
  double _width = 300;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _width,
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
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _width = (_width - details.delta.dx).clamp(180, 500);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 5,
              color: themeData.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
