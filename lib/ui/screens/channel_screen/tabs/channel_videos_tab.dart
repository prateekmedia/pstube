import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/channel_screen/state/channel_notifier.dart';
import 'package:pstube/ui/widgets/widgets.dart' hide ChannelDetails;

class ChannelVideosTab extends HookConsumerWidget {
  const ChannelVideosTab({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelP = ref.watch(channelProvider);
    final videos = channelP.videos;

    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: videos != null ? videos.length + 1 : 1,
      itemBuilder: (ctx, index) {
        final loading = index == videos?.length;

        if (loading) return getCircularProgressIndicator();

        final videoData = videos![index];

        return PSVideo(
          date: videoData.uploadDate,
          videoData: videoData,
          loadData: true,
          showChannel: false,
          isRow: !context.isMobile,
        );
      },
    );
  }
}
