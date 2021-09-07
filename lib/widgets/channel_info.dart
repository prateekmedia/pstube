import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';

class ChannelInfo extends StatelessWidget {
  const ChannelInfo({
    Key? key,
    required this.channel,
    this.isOnVideo = false,
  }) : super(key: key);

  final AsyncSnapshot<Channel> channel;
  final bool isOnVideo;

  @override
  Widget build(BuildContext context) {
    double size = isOnVideo ? 40 : 60;
    return GestureDetector(
      onTap: isOnVideo && channel.data != null
          ? () {
              context.pushPage(ChannelScreen(id: channel.data!.id.value));
            }
          : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(children: [
              ChannelLogo(channel: channel.data, size: size),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.data != null ? channel.data!.title : "",
                    style: context.textTheme.headline6,
                  ),
                  Text(
                    channel.data != null
                        ? channel.data!.subscribersCount == null
                            ? "Hidden"
                            : channel.data!.subscribersCount!.formatNumber +
                                " subscribers"
                        : "",
                    style: context.textTheme.bodyText1!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
