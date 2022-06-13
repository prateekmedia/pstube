import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';

class ChannelHomeTab extends StatelessWidget {
  const ChannelHomeTab({
    super.key,
    required this.channel,
  });

  final ChannelInfo? channel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (channel!.bannerUrl != null)
          CachedNetworkImage(
            imageUrl: channel!.bannerUrl!,
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  decoration: channel!.avatarUrl != null
                      ? BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              channel!.avatarUrl!,
                            ),
                          ),
                          color: Colors.grey,
                        )
                      : null,
                  height: 80,
                  width: 80,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(channel!.name ?? ''),
                  Text(
                    channel!.subscriberCount != null
                        ? '${channel!.subscriberCount!.addCommas} ${context.locals.subscribers}'
                        : context.locals.hidden,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
