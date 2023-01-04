import 'package:pstube/data/models/channel_data.dart';
import 'package:pstube/data/models/models.dart';

enum SearchType { channel, playlist, video }

class SearchData {
  SearchData({
    required this.data,
  });

  final dynamic data;
  SearchType get type => data is VideoData
      ? SearchType.video
      : data is ChannelData
          ? SearchType.channel
          : SearchType.playlist;
}
