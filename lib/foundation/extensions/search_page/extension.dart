import 'package:flutter/material.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/video_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/widgets/widgets.dart';

extension BSC on SearchItem {
  Widget showContent(BuildContext context) {
    if (subscribers != null) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ChannelDetails(
          channelId: uploaderUrl!,
        ),
      );
    } else if (views != null) {
      return PSVideo(
        videoData: VideoData.fromSearchItem(this),
        isRow: !context.isMobile,
        loadData: true,
      );
    } else {
      return PSPlaylist.searchItem(
        searchItem: this,
      );
    }
  }
}
