import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/widgets/widgets.dart' hide ChannelDetails;

class ChannelVideosTab extends HookWidget {
  const ChannelVideosTab({
    super.key,
    required this.currentVidPage,
    required this.channel,
  });

  final ChannelInfo? channel;
  final ValueNotifier<BuiltList<StreamItem>?> currentVidPage;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount:
          currentVidPage.value != null ? currentVidPage.value!.length + 1 : 1,
      itemBuilder: (ctx, index) {
        final loading = index == currentVidPage.value!.length;

        if (loading) return getCircularProgressIndicator();

        final streamItem = currentVidPage.value![index];

        return PSVideo.streamItem(
          date: streamItem.uploadedDate,
          streamItem: streamItem,
          loadData: true,
          showChannel: false,
          isRow: !context.isMobile,
        );
      },
    );
  }
}
