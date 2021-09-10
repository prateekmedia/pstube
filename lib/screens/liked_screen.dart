import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LikedScreen extends StatefulHookWidget {
  const LikedScreen({Key? key}) : super(key: key);

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final tabController = useTabController(initialLength: 2);

    return Consumer(builder: (context, ref, _) {
      final likedList = ref.watch(likedListProvider);
      return Column(
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            controller: tabController,
            tabs: const [
              Tab(text: "Videos"),
              Tab(text: "Comments"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  children: [
                    if (likedList.likedVideoList.isEmpty) ...[
                      const SizedBox(height: 60),
                      const Icon(Icons.thumbs_up_down, size: 30),
                      const SizedBox(height: 10),
                      const Text('No Liked videos found').center()
                    ] else
                      for (String url in likedList.likedVideoList)
                        FTVideo(
                          videoUrl: url,
                          isRow: !context.isMobile,
                        ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  children: [
                    if (likedList.likedVideoList.isEmpty) ...[
                      const SizedBox(height: 60),
                      const Icon(Icons.thumbs_up_down, size: 30),
                      const SizedBox(height: 10),
                      const Text('No Liked comments found').center()
                    ] else
                      for (Comment comment in likedList.likedCommentList)
                        BuildCommentBox(
                          comment: comment,
                          onReplyTap: () {},
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
