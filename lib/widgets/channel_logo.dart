import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutube/utils/utils.dart';

class ChannelLogo extends HookWidget {
  final Channel? channel;
  final ChannelId? channelId;
  final double size;
  const ChannelLogo({Key? key, this.channel, this.size = 60, this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chid = channelId != null ? useFuture(useMemoized(() => YoutubeExplode().channels.get(channelId))) : null;
    final bool channelHasData = channel != null || chid != null && chid.hasData;
    final Channel? channelData = channelHasData ? channel ?? chid!.data : null;
    final Color bgColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];

    final Widget defaultPlaceholder = channelHasData
        ? Center(
            child: Text(
              channelData!.title.characters.first,
              style: context.textTheme.headline5!.copyWith(
                fontWeight: FontWeight.w500,
                color: bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              ),
            ),
          )
        : Container();
    return ClipOval(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: bgColor),
        child: channelHasData
            ? CachedNetworkImage(
                imageUrl: channelData!.logoUrl,
                errorWidget: (_, __, ___) => defaultPlaceholder,
                placeholder: (_, __) => defaultPlaceholder,
                fit: BoxFit.fitWidth,
              )
            : null,
      ),
    );
  }
}
