import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutube/utils/utils.dart';

class ChannelLogo extends HookWidget {
  final AsyncSnapshot<Channel>? channel;
  final double size;
  const ChannelLogo({Key? key, this.channel, this.size = 60}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool channelHasData = channel != null && channel!.hasData;
    final Channel? channelData = channelHasData ? channel!.data : null;
    final Color bgColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];

    final Widget defaultPlaceholder = Container(
      width: size,
      height: size,
      color: bgColor,
      child: Center(
        child: Text(
          channelHasData ? channelData!.title.characters.first : "...",
          style: context.textTheme.headline5!.copyWith(
            fontWeight: FontWeight.w500,
            color: bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
    return ClipOval(
      child: channelHasData
          ? CachedNetworkImage(
              width: size,
              height: size,
              imageUrl: channelData!.logoUrl,
              errorWidget: (_, __, ___) => defaultPlaceholder,
              placeholder: (_, __) => defaultPlaceholder,
              fit: BoxFit.contain,
            )
          : defaultPlaceholder,
    );
  }
}
