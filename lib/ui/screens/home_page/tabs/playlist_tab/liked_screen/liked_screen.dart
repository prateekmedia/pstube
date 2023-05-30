import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/states/liked_list/liked_list.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/screens/video_screen/src/build_comment_box.dart';
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
    final controller = PageController();
    final currentIndex = useState<int>(0);
    final tabs = {
      context.locals.videos: LucideIcons.video,
      context.locals.comments: LucideIcons.messageCircle,
    };

    return Consumer(
      builder: (context, ref, _) {
        final likedList = ref.watch(likedListProvider);
        return AdwScaffold(
          actions: AdwActions().windowManager,
          start: [
            context.backLeading(),
          ],
          viewSwitcher: AdwViewSwitcher(
            currentIndex: currentIndex.value,
            onViewChanged: controller.jumpToPage,
            tabs: tabs.entries
                .map(
                  (e) => ViewSwitcherData(
                    title: e.key,
                    icon: e.value,
                  ),
                )
                .toList(),
          ),
          body: PageView(
            controller: controller,
            onPageChanged: (page) => currentIndex.value = page,
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
    required this.likedList,
    super.key,
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
    required this.likedList,
    super.key,
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
            BuildCommentBox.liked(
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
