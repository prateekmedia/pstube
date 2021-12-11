import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            labelColor: context.textTheme.bodyText1!.color,
            tabs: const [
              Tab(text: "Videos"),
              Tab(text: "Comments"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                LikedVideoList(likedList: likedList),
                LikedCommentList(likedList: likedList),
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

class LikedVideoList extends StatefulWidget {
  const LikedVideoList({
    Key? key,
    required this.likedList,
  }) : super(key: key);

  final LikedList likedList;

  @override
  State<LikedVideoList> createState() => _LikedVideoListState();
}

class _LikedVideoListState extends State<LikedVideoList> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      children: [
        if (widget.likedList.likedVideoList.isEmpty) ...[
          const SizedBox(height: 60),
          const FaIcon(FontAwesomeIcons.solidThumbsUp, size: 30),
          const SizedBox(height: 10),
          const Text('No Liked videos found').center()
        ] else
          for (String url in widget.likedList.likedVideoList)
            FTVideo(
              videoUrl: url,
              isRow: !context.isMobile,
            ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LikedCommentList extends StatefulWidget {
  const LikedCommentList({
    Key? key,
    required this.likedList,
  }) : super(key: key);

  final LikedList likedList;

  @override
  State<LikedCommentList> createState() => _LikedCommentListState();
}

class _LikedCommentListState extends State<LikedCommentList> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      children: [
        if (widget.likedList.likedCommentList.isEmpty) ...[
          const SizedBox(height: 60),
          const FaIcon(FontAwesomeIcons.thumbsUp, size: 30),
          const SizedBox(height: 10),
          const Text('No Liked comments found').center()
        ] else
          for (LikedComment comment in widget.likedList.likedCommentList)
            CommentBox(
              comment: comment,
              onReplyTap: null,
              updateLike: () => widget.likedList.removeComment(comment),
            ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
