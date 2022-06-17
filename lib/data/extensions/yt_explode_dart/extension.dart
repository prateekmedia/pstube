// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:youtube_explode_dart/src/search/base_search_content.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension BSC on BaseSearchContent {
  Widget showContent(BuildContext context) {
    if (this is SearchChannel) {
      final item = this as SearchChannel;
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ChannelInfo(
          channel: null,
          channelId: item.id.value,
        ),
      );
    } else if (this is SearchVideo) {
      final item = this as SearchVideo;
      return PSVideo(
        videoData: (this as SearchVideo).toVideo,
        isRow: !context.isMobile,
        date: item.uploadDate,
        duration: item.duration,
        loadData: true,
      );
    } else {
      final item = this as SearchPlaylist;
      return PSPlaylist(
        playlist: item,
      );
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
      uploadDate,
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
