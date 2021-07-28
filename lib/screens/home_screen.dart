import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutube/widgets/widgets.dart';
import '../utils/utils.dart';

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
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        StaggeredGridView.countBuilder(
          staggeredTileBuilder: (idx) => StaggeredTile.fit(context.width > 1200
              ? 3
              : context.width > 900
                  ? 4
                  : context.width > 700
                      ? 6
                      : 12),
          crossAxisCount: 12,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (ctx, idx) => const FTVideo(
            videoUrl: 'https://www.youtube.com/watch?v=WhWc3b3KhnY',
          ),
          itemCount: 4,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
