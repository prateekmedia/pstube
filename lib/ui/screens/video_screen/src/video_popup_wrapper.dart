import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

class VideoPopupWrapper extends StatelessWidget {
  const VideoPopupWrapper({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
  });

  final Widget child;
  final VoidCallback onClose;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdwHeaderBar(
          style: const HeaderBarStyle(
            autoPositionWindowButtons: false,
            height: 46,
          ),
          title: Text(title),
          actions: AdwActions(
            onClose: onClose,
            onHeaderDrag: appWindow?.startDragging,
            onDoubleTap: appWindow?.maximizeOrRestore,
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: context.theme.canvasColor,
            child: WillPopScope(
              child: SingleChildScrollView(
                controller: ScrollController(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: child,
              ),
              onWillPop: () async {
                context.back();
                return false;
              },
            ),
          ),
        ),
      ],
    );
  }
}
