import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/channel_data.dart';
import 'package:pstube/data/models/models.dart';

extension BSC on SearchItem {
  dynamic get data {
    if (oneOf.valueType is ChannelItem) {
      final item = oneOf.value! as ChannelItem;
      return ChannelData.fromChannelItem(item);
    } else if (oneOf.valueType is StreamItem) {
      final item = oneOf.value! as StreamItem;
      return VideoData.fromStreamItem(item);
    } else {
      final item = oneOf.value! as PlaylistItem;
      return PlaylistData.fromPlaylistItem(searchItem: item);
    }
  }
}
