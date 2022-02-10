import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutube/providers/providers.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:piped_api/piped_api.dart';

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final shown = useState<int>(18);

    final videos = useMemoized(
      () => PipedApi().getUnauthenticatedApi().trending(
            region: ref.watch(regionProvider),
          ),
    );
    return FutureBuilder<Response>(
      future: videos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    itemBuilder: (ctx, idx) =>
                        shown.value < (snapshot.data!.data.length as int) &&
                                idx == shown.value
                            ? AdwButton(
                                onPressed: () => shown.value += 20,
                                child: const Text('Load more'),
                              )
                            : FTVideo(
                                videoUrl:
                                    'https://youtube.com${(snapshot.data!.data[idx] as StreamItem).url}',
                              ),
                    itemCount:
                        min(snapshot.data!.data.length as int, shown.value + 1),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
