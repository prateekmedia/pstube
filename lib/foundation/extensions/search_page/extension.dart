import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/channel_data.dart';
import 'package:pstube/data/models/models.dart';

extension BSC on SearchItem {
  dynamic get data {
    if (oneOf is ChannelItem) {
      final item = this as ChannelItem;
      return ChannelData.fromChannelItem(item);
    } else if (oneOf is StreamItem) {
      final item = this as StreamItem;
      return VideoData.fromStreamItem(item);
    } else {
      final item = this as PlaylistItem;
      return PlaylistData.fromPlaylistItem(searchItem: item);
    }
  }
}
