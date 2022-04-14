// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:pstube/utils/extensions/context.dart';
import 'package:pstube/widgets/channel_info.dart';
import 'package:pstube/widgets/ps_video.dart';
import 'package:youtube_explode_dart/src/search/base_search_content.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension BSC on BaseSearchContent {
  Widget showContent(BuildContext context) {
    if (this is SearchChannel) {
      return ChannelInfo(
        channel: null,
        channelId: (this as SearchChannel).id.value,
      );
    } else if (this is SearchVideo) {
      return SFVideo(
        videoData: (this as SearchVideo).toVideo,
        isRow: !context.isMobile,
        date: (this as SearchVideo).uploadDate,
        duration: (this as SearchVideo).duration,
        loadData: true,
      );
    } else {
      return Container();
    }
  }
}

extension SVE on SearchVideo {
  Video get toVideo {
    return Video(
      id,
      title,
      author,
      ChannelId(channelId),
      DateTime.now(),
      DateTime.now(),
      description,
      Duration.zero,
      ThumbnailSet(id.value),
      [],
      Engagement(viewCount, 0, 0),
      isLive,
    );
  }
}
