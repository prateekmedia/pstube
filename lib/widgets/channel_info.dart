import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';

class ChannelInfo extends StatefulWidget {
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

class _ChannelInfoState extends State<ChannelInfo> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double size = widget.isOnVideo ? 40 : 60;
    final yt = YoutubeExplode();
    return FutureBuilder<Channel?>(
        future: widget.channelId != null ? yt.channels.getByUsername(widget.channelId) : null,
        builder: (context, snapshot) {
          final Channel? data = widget.channel?.data ?? snapshot.data;
          return GestureDetector(
            onTap: widget.isOnVideo && data != null || widget.channelId != null
                ? () {
                    context.pushPage(ChannelScreen(id: widget.channelId ?? data!.id.value));
                  }
                : null,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(children: [
                    ChannelLogo(channel: data, size: size),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data != null ? data.title : "",
                          style: context.textTheme.headline6!.copyWith(color: widget.textColor),
                        ),
                        Text(
                          data != null
                              ? data.subscribersCount == null
                                  ? "Hidden"
                                  : data.subscribersCount!.formatNumber + " subscribers"
                              : "",
                          style: context.textTheme.bodyText1!.copyWith(color: widget.textColor),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
