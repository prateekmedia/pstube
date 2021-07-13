import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';

class ChannelScreen extends StatelessWidget {
  final String id;
  const ChannelScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Channel>(
          future: YoutubeExplode().channels.get('UCBefBxNTPoNCQBU_Lta6Nvg'),
          builder: (context, snapshot) {
            return snapshot.hasData && snapshot.data != null
                ? ListView(
                    children: [
                      Container(
                        width: 100,
                        margin: EdgeInsets.symmetric(vertical: 12),
                        height: 100,
                        decoration: ShapeDecoration(
                            shape: CircleBorder(),
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    snapshot.data!.logoUrl))),
                      ),
                      Center(
                        child: Text(
                          snapshot.data!.title,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Center(
                        child: Text(
                          snapshot.data!.id
                              .value, // .formatNumber + " Subscribers",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator().center();
          }),
    );
  }
}
