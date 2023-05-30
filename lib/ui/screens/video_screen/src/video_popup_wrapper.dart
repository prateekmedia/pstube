import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

class VideoPopupWrapper extends StatelessWidget {
  const VideoPopupWrapper({
    required this.title,
    required this.onClose,
    required this.child,
    super.key,
    this.isScrollable = true,
    this.start = const [],
  });

  final Widget child;
  final VoidCallback onClose;
  final String title;
  final bool isScrollable;
  final List<Widget> start;

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
          start: start,
          actions: AdwActions(
            onClose: onClose,
            onHeaderDrag: AdwActions().windowManager.onHeaderDrag,
            onDoubleTap: AdwActions().windowManager.onDoubleTap,
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: context.theme.canvasColor,
            child: WillPopScope(
              child: isScrollable
                  ? SingleChildScrollView(
                      controller: ScrollController(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      child: child,
                    )
                  : child,
              onWillPop: () async {
                onClose();
                return false;
              },
            ),
          ),
        ),
      ],
    );
  }
}
