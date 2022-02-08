import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:piped_api/piped_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final videos =
        PipedApi().getUnauthenticatedApi().trending(region: Regions.IN);
    print(videos);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<Response>(
              future: videos,
              builder: (context, snapshot) {
                print(snapshot.data?.data);
                if (snapshot.hasData) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 6 * 300),
                    child: MasonryGridView.count(
                      crossAxisCount: (context.width ~/ 300 as int).clamp(1, 6),
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (ctx, idx) => FTVideo(
                        videoUrl: "https://youtube.com" +
                            (snapshot.data!.data[idx] as StreamItem).url,
                      ),
                      itemCount: snapshot.data!.data.length,
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
