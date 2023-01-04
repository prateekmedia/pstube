import 'package:built_collection/built_collection.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/models.dart';

class ChannelData {
  ChannelData({
    required this.name,
    required this.bannerUrl,
    required this.avatarUrl,
    required this.subscriberCount,
    required this.description,
    required this.id,
    required this.verified,
    required this.videos,
  });

  ChannelData.fromChannelInfo({
    required ChannelInfo channelInfo,
  })  : name = channelInfo.name!,
        bannerUrl = channelInfo.bannerUrl,
        avatarUrl = channelInfo.avatarUrl!,
        subscriberCount = channelInfo.subscriberCount ?? -1,
        description = channelInfo.description ?? '',
        id = UploaderId(channelInfo.id!),
        verified = channelInfo.verified ?? false,
        videos = channelInfo.relatedStreams != null
            ? StreamList(
                streams: channelInfo.relatedStreams!
                    .map(
                      VideoData.fromStreamItem,
                    )
                    .toBuiltList(),
                nextpage: channelInfo.nextpage,
              )
            : null;

  ChannelData.fromChannelItem(ChannelItem item)
      : name = item.name!,
        bannerUrl = '',
        avatarUrl = item.thumbnail!,
        subscriberCount = item.subscribers ?? -1,
        description = item.description ?? '',
        id = UploaderId(item.url!),
        verified = item.verified ?? false,
        videos = null;

  final String name;
  final String? bannerUrl;
  final String avatarUrl;
  final int subscriberCount;
  final String description;
  final UploaderId id;
  final bool verified;
  final StreamList<VideoData>? videos;
}
