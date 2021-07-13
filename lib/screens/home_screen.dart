import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutube/widgets/widgets.dart';
import '../utils/utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
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
          itemBuilder: (ctx, idx) => FTVideo(
            videoUrl: 'https://www.youtube.com/watch?v=CYDP_8UTAus',
          ),
          itemCount: 4,
        ),
      ],
    );
  }
}
