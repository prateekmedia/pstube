import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pstube/data/models/channel_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

class ChannelHomeTab extends StatelessWidget {
  const ChannelHomeTab({
    required this.channel,
    super.key,
  });

  final ChannelData? channel;

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
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        channel!.avatarUrl,
                      ),
                    ),
                    color: Colors.grey,
                  ),
                  height: 80,
                  width: 80,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(channel!.name),
                  Text(
                    channel!.subscriberCount != -1
                        ? '${channel!.subscriberCount.addCommas} ${context.locals.subscribers}'
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
