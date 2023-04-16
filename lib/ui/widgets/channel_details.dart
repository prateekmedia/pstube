import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/screens.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class ChannelDetails extends StatefulHookWidget {
  const ChannelDetails({
    super.key,
    required this.channelId,
    this.textColor,
    this.isOnVideo = false,
  });

  final String channelId;
  final bool isOnVideo;
  final Color? textColor;

  @override
  State<ChannelDetails> createState() => _ChannelInfoState();
}

class _ChannelInfoState extends State<ChannelDetails>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = widget.isOnVideo ? 40 : 60;
    final api = PipedApi().getUnauthenticatedApi();
    final channelData = useFuture<Response<ChannelInfo>>(
      useMemoized(
        () => api.channelInfoId(
          channelId: widget.channelId,
        ),
        [
          widget.channelId,
        ],
      ),
    ).data?.data;

    return GestureDetector(
      onTap: widget.isOnVideo && channelData != null
          ? () => context.pushPage(
                ChannelScreen(
                  channelId: widget.channelId,
                ),
              )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            ChannelLogo(
              channel: channelData,
              size: size.toDouble(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelData?.name ?? '',
                    overflow: TextOverflow.clip,
                    style: context.textTheme.headlineMedium,
                  ),
                  Text(
                    channelData != null
                        ? channelData.subscriberCount == null ||
                                channelData.subscriberCount == -1
                            ? context.locals.hidden
                            : '${channelData.subscriberCount!.formatNumber} '
                                '${context.locals.subscribers}'
                        : '',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            AdwButton.flat(
              onPressed: () {},
              child: Text(
                'SUBSCRIBE',
                style: TextStyle(
                  color:
                      context.theme.primaryColor.brightenReverse(context, 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
