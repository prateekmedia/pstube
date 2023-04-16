import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/channel_screen/state/channel_notifier.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelAboutTab extends ConsumerWidget {
  const ChannelAboutTab({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelP = ref.watch(channelProvider);
    final channelInfo = channelP.channelInfo;

    final getStats = (channelInfo != null)
        ? [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.locals.stats,
                style: context.textTheme.headlineSmall,
              ),
            ),
            const Divider(height: 26),
            Text(
              '${context.locals.joined} ${channelInfo.joinDate}',
              style: context.textTheme.bodyMedium,
            ),
            const Divider(height: 26),
            Text(
              '${(channelInfo.viewCount ?? 0).addCommas} '
              '${context.locals.views}',
              style: context.textTheme.bodyMedium,
            ),
            if (channelInfo.country != null) ...[
              const Divider(height: 26),
              Text(channelInfo.country!),
            ],
          ]
        : <Widget>[];

    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          flex: 6,
          child: ListView(
            primary: false,
            controller: ScrollController(),
            shrinkWrap: true,
            children: [
              if (channelInfo!.description != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.locals.description,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                SelectableText(
                  channelInfo.description!,
                ),
              ],
              if (channelInfo.channelLinks.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.locals.links,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                Wrap(
                  children: [
                    for (ChannelLink link in channelInfo.channelLinks)
                      AdwButton.pill(
                        onPressed: link.url.toString().launchIt,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 3,
                        ),
                        child: Text(link.title),
                      )
                  ],
                ),
              ],
              if (context.isMobile) ...[
                const Divider(),
                ...getStats,
              ]
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (!context.isMobile)
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getStats,
            ),
          ),
      ],
    );
  }
}
