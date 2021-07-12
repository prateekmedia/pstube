import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';

class ChannelScreen extends StatelessWidget {
  final Channel channel;
  const ChannelScreen({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
              shape: CircleBorder(),
              image: DecorationImage(
                  image:
                      CachedNetworkImageProvider(channel.profilePictureUrl))),
        ),
        Text(channel.title),
      ],
    );
  }
}
