import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:flutube/utils/utils.dart';

class ChannelInfo extends HookWidget {
  const ChannelInfo({
    Key? key,
    required this.channel,
    this.channelId,
    this.textColor,
    this.isOnVideo = false,
  })  : assert(channel != null || channelId != null),
        super(key: key);

  final AsyncSnapshot<Channel>? channel;
  final String? channelId;
  final bool isOnVideo;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    double size = isOnVideo ? 40 : 60;
    final yt = YoutubeExplode();
    final channelData = channelId != null
        ? useFuture(useMemoized(() => yt.channels.get(channelId), [channelId!]))
        : channel;
    final Channel? data = channel?.data ?? channelData?.data;
    return GestureDetector(
      onTap: isOnVideo && data != null || channelId != null
          ? () =>
              context.pushPage(ChannelScreen(id: channelId ?? data!.id.value))
          : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(children: [
              ChannelLogo(channel: channelData, size: size),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data != null ? data.title : "",
                    style: context.textTheme.headline4,
                  ),
                  Text(
                    data != null
                        ? data.subscribersCount == null
                            ? "Hidden"
                            : data.subscribersCount!.formatNumber +
                                " subscribers"
                        : "",
                    style: context.textTheme.bodyText2,
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
