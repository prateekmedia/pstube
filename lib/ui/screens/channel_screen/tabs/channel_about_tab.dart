import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelAboutTab extends StatelessWidget {
  const ChannelAboutTab({
    super.key,
    required this.channelInfo,
  });

  final ChannelAbout? channelInfo;

  @override
  Widget build(BuildContext context) {
    final getStats = (channelInfo != null)
        ? [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.locals.stats,
                style: context.textTheme.headline5,
              ),
            ),
            const Divider(height: 26),
            Text(
              '${context.locals.joined} ${channelInfo!.joinDate}',
              style: context.textTheme.bodyText2,
            ),
            const Divider(height: 26),
            Text(
              '${(channelInfo!.viewCount ?? 0).addCommas} '
              '${context.locals.views}',
              style: context.textTheme.bodyText2,
            ),
            if (channelInfo!.country != null) ...[
              const Divider(height: 26),
              Text(channelInfo!.country!),
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
                    style: context.textTheme.headline5,
                  ),
                ),
                SelectableText(
                  channelInfo!.description!,
                ),
              ],
              if (channelInfo!.channelLinks.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.locals.links,
                    style: context.textTheme.headline5,
                  ),
                ),
                Wrap(
                  children: [
                    for (ChannelLink link in channelInfo!.channelLinks)
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
                        //   labelStyle: context.textTheme.bodyText2,
                        // ),
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
