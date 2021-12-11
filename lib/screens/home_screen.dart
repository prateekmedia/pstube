import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      controller: ScrollController(),
      physics: const BouncingScrollPhysics(),
      children: [
        MasonryGridView.count(
          crossAxisCount: context.width > 1200
              ? 4
              : context.width > 900
                  ? 3
                  : context.width > 620
                      ? 2
                      : 1,
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
