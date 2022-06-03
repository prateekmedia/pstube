import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';

import 'package:pstube/ui/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<Response> snapshot;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return (widget.snapshot.hasData)
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
                    itemBuilder: (ctx, idx) {
                      final streamItem =
                          widget.snapshot.data!.data[idx] as StreamItem;
                      return PSVideo(
                        loadData: true,
                        date: streamItem.uploadedDate,
                        videoData: streamItem.toVideo,
                      );
                    },
                    itemCount: widget.snapshot.data!.data.length as int,
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
