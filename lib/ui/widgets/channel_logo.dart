import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

class ChannelLogo extends StatefulHookWidget {
  const ChannelLogo({
    super.key,
    this.channel,
    this.size = 60,
    this.author,
  });

  final ChannelInfo? channel;
  final double size;
  final String? author;

  @override
  State<ChannelLogo> createState() => _ChannelLogoState();
}

class _ChannelLogoState extends State<ChannelLogo>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final channelHasData = widget.channel != null;
    final channelData = channelHasData ? widget.channel! : null;
    final Color bgColor =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];

    final Widget defaultPlaceholder = Container(
      width: widget.size,
      height: widget.size,
      color: bgColor,
      child: Center(
        child: Text(
          channelData?.name?.characters.first ?? widget.author?[0] ?? '...',
          style: context.textTheme.headline5!.copyWith(
            fontWeight: FontWeight.w500,
            color:
                bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
    return ClipOval(
      child: channelHasData
          ? CachedNetworkImage(
              width: widget.size,
              height: widget.size,
              imageUrl: channelData?.avatarUrl ?? '',
              errorWidget: (_, __, dynamic ___) => defaultPlaceholder,
              placeholder: (_, __) => defaultPlaceholder,
              fit: BoxFit.contain,
            )
          : defaultPlaceholder,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
