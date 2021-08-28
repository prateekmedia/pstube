import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelLogo extends HookWidget {
  final Channel? channel;
  final ChannelId? channelId;
  final double size;
  const ChannelLogo({Key? key, this.channel, this.size = 60, this.channelId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chid = channelId != null
        ? useFuture(useMemoized(() => YoutubeExplode().channels.get(channelId)))
        : null;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(1000),
        image: channel != null || chid != null && chid.hasData
            ? DecorationImage(
                image: CachedNetworkImageProvider(
                    (channel ?? chid!.data)!.logoUrl),
                fit: BoxFit.fitWidth,
              )
            : null,
      ),
    );
  }
}
