// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/video_data.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:youtube_explode_dart/src/search/base_search_content.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension BSC on BaseSearchContent {
  Widget showContent(BuildContext context) {
    if (this is SearchChannel) {
      final searchChannel = this as SearchChannel;
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ChannelInfo(
          channel: null,
          channelId: searchChannel.id.value,
        ),
      );
    } else if (this is SearchVideo) {
      final searchVideo = this as SearchVideo;
      return PSVideo(
        videoData: VideoData.fromSearchVideo(searchVideo),
        isRow: !context.isMobile,
        date: searchVideo.uploadDate,
        duration: searchVideo.duration,
        loadData: true,
      );
    } else {
      final searchPlaylist = this as SearchPlaylist;
      return PSPlaylist(
        playlist: searchPlaylist,
      );
    }
  }
}
