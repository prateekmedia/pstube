import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 6 * 300),
            child: MasonryGridView.count(
              crossAxisCount: (context.width ~/ 300 as int).clamp(1, 6),
              shrinkWrap: true,
              primary: false,
              itemBuilder: (ctx, idx) => const FTVideo(
                videoUrl: 'https://www.youtube.com/watch?v=WhWc3b3KhnY',
              ),
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
