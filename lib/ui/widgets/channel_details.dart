import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                ChannelLogo(
                  channel: channelData,
                  size: size.toDouble(),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channelData?.name ?? '',
                      style: context.textTheme.headline4,
                    ),
                    Text(
                      channelData != null
                          ? channelData.subscriberCount == null
                              ? context.locals.hidden
                              : '${channelData.subscriberCount!.formatNumber} '
                                  '${context.locals.subscribers}'
                          : '',
                      style: context.textTheme.bodyText2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
