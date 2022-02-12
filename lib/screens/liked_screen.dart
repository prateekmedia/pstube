import 'package:ant_icons/ant_icons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';

import 'package:sftube/models/models.dart';
import 'package:sftube/providers/providers.dart';
import 'package:sftube/utils/utils.dart';
import 'package:sftube/widgets/widgets.dart';

class LikedScreen extends StatefulHookWidget {
  const LikedScreen({Key? key}) : super(key: key);

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _controller = PageController();
    final _currentIndex = useState<int>(0);
    final _tabs = [
      context.locals.videos,
      context.locals.comments,
    ];

    return Consumer(
      builder: (context, ref, _) {
        final likedList = ref.watch(likedListProvider);
        return AdwScaffold(
          headerbar: (viewSwitcher) => AdwHeaderBar.bitsdojo(
            appWindow: getAppwindow(appWindow),
            start: [context.backLeading()],
            title: viewSwitcher,
          ),
          viewSwitcher: AdwViewSwitcher(
            currentIndex: _currentIndex.value,
            onViewChanged: _controller.jumpToPage,
            tabs: _tabs.map((e) => ViewSwitcherData(title: e)).toList(),
          ),
          body: PageView(
            controller: _controller,
            onPageChanged: (page) => _currentIndex.value = page,
            children: [
              LikedVideoList(likedList: likedList),
              LikedCommentList(likedList: likedList),
            ],
          ),
        );
      },
    );
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

class _LikedVideoListState extends State<LikedVideoList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        if (widget.likedList.likedVideoList.isEmpty) ...[
          const SizedBox(height: 60),
          const Icon(AntIcons.like, size: 30),
          const SizedBox(height: 10),
          Text(context.locals.noLikedVideosFound).center()
        ] else
          for (final url in widget.likedList.likedVideoList)
            SFVideo(
              videoUrl: url as String,
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

class _LikedCommentListState extends State<LikedCommentList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        if (widget.likedList.likedCommentList.isEmpty) ...[
          const SizedBox(height: 60),
          const Icon(AntIcons.like, size: 30),
          const SizedBox(height: 10),
          Text(context.locals.noLikedCommentsFound).center()
        ] else
          for (final comment in widget.likedList.likedCommentList)
            CommentBox(
              comment: comment,
              onReplyTap: null,
              updateLike: () =>
                  widget.likedList.removeComment(comment as LikedComment),
            ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
