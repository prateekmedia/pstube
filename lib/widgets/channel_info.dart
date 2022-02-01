import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:flutube/utils/utils.dart';

class ChannelInfo extends StatefulHookWidget {
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
  State<ChannelInfo> createState() => _ChannelInfoState();
}

class _ChannelInfoState extends State<ChannelInfo>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double size = widget.isOnVideo ? 40 : 60;
    final yt = YoutubeExplode();
    final channelData = widget.channelId != null
        ? useFuture(useMemoized(
            () => yt.channels.get(widget.channelId), [widget.channelId!]))
        : widget.channel;
    final Channel? data = widget.channel?.data ?? channelData?.data;
    return GestureDetector(
      onTap: widget.isOnVideo && data != null || widget.channelId != null
          ? () => context
              .pushPage(ChannelScreen(id: widget.channelId ?? data!.id.value))
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
                            ? context.locals.hidden
                            : data.subscribersCount!.formatNumber +
                                " " +
                                context.locals.subscribers
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

  @override
  bool get wantKeepAlive => true;
}
