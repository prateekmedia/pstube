import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/ui/states/liked_list/liked_list.dart';
import 'package:pstube/ui/states/states.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class LikedScreen extends StatefulHookWidget {
  const LikedScreen({super.key});

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
    final _tabs = {
      context.locals.videos: LucideIcons.video,
      context.locals.comments: LucideIcons.messageCircle,
    };

    return Consumer(
      builder: (context, ref, _) {
        final likedList = ref.watch(likedListProvider);
        return AdwScaffold(
          actions: AdwActions().bitsdojo,
          start: [
            context.backLeading(),
          ],
          viewSwitcher: AdwViewSwitcher(
            currentIndex: _currentIndex.value,
            onViewChanged: _controller.jumpToPage,
            tabs: _tabs.entries
                .map(
                  (e) => ViewSwitcherData(
                    title: e.key,
                    icon: e.value,
                  ),
                )
                .toList(),
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
    super.key,
    required this.likedList,
  });

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
          const Icon(LucideIcons.thumbsUp, size: 30),
          const SizedBox(height: 10),
          Text(context.locals.noLikedVideosFound).center()
        ] else
          for (final url in widget.likedList.likedVideoList)
            PSVideo(
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
    super.key,
    required this.likedList,
  });

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
          const Icon(LucideIcons.thumbsUp, size: 30),
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
