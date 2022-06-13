import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/ui/widgets/widgets.dart' hide ChannelInfo;

class ChannelVideosTab extends StatelessWidget {
  const ChannelVideosTab({
    super.key,
    required this.controller,
    required ValueNotifier<BuiltList<StreamItem>?> currentVidPage,
  }) : _currentVidPage = currentVidPage;

  final ScrollController controller;
  final ValueNotifier<BuiltList<StreamItem>?> _currentVidPage;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      controller: controller,
      itemCount:
          _currentVidPage.value != null ? _currentVidPage.value!.length + 1 : 1,
      itemBuilder: (ctx, index) {
        final loading = index == _currentVidPage.value!.length;

        if (loading) return getCircularProgressIndicator();

        final streamItem = _currentVidPage.value![index];

        return PSVideo(
          date: streamItem.uploadedDate,
          videoData: streamItem.toVideo,
          loadData: true,
          showChannel: false,
          isRow: true,
        );
      },
    );
  }
}
