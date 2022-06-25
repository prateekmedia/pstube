import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';

import 'package:pstube/ui/widgets/widgets.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<Response<BuiltList<StreamItem>>> snapshot;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return (widget.snapshot.hasData &&
            widget.snapshot.data != null &&
            widget.snapshot.data!.data != null)
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
                      final streamItem = widget.snapshot.data!.data![idx];
                      return PSVideo.streamItem(
                        loadData: true,
                        streamItem: streamItem,
                      );
                    },
                    itemCount: widget.snapshot.data!.data!.length,
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
