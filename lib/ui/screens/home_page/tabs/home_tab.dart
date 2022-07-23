import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/services/piped_service.dart';

import 'package:pstube/ui/widgets/widgets.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({
    super.key,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final videos = ref.watch(trendingVideosProvider);

    return (videos.asData != null)
        ? SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 6 * 300),
                  child: MasonryGridView.builder(
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (context.width ~/ 300).clamp(1, 6),
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (ctx, idx) => PSVideo(
                      loadData: true,
                      videoData: videos.value![idx],
                    ),
                    itemCount: videos.value!.length,
                  ),
                ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  @override
  bool get wantKeepAlive => true;
}
