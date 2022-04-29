import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:pstube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ShowDownloadsWidget extends StatelessWidget {
  const ShowDownloadsWidget({
    Key? key,
    required this.downloadsSideWidget,
    required this.videoData,
    this.manifest,
  }) : super(key: key);

  final ValueNotifier<Widget?> downloadsSideWidget;
  final Video videoData;
  final StreamManifest? manifest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdwHeaderBar(
          style: const HeaderBarStyle(
            autoPositionWindowButtons: false,
          ),
          title: Text(
            context.locals.downloadQuality,
          ),
          actions: AdwActions(
            onClose: () => downloadsSideWidget.value = null,
            onHeaderDrag: appWindow?.startDragging,
            onDoubleTap: appWindow?.maximizeOrRestore,
          ),
        ),
        Expanded(
          child: Container(
            color: context.theme.canvasColor,
            child: WillPopScope(
              child: SingleChildScrollView(
                controller: ScrollController(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: DownloadsWidget(
                  video: videoData,
                  onClose: () => downloadsSideWidget.value = null,
                ),
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
