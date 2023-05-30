import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pstube/data/models/comment_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:pstube/ui/screens/video_screen/view_model/comments_view_model.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class CommentsWidget extends StatefulHookConsumerWidget {
  const CommentsWidget({
    required this.onClose,
    required this.videoId,
    super.key,
  });

  final String videoId;
  final VoidCallback onClose;

  @override
  ConsumerState<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends ConsumerState<CommentsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isMounted = useIsMounted();
    final pageController = PageController();
    final controller = useScrollController();
    final currentPage = useState<int>(0);
    final commentsP = ref.watch(commentsProvider);
    final replyComment = commentsP.replyComment;
    final comments = commentsP.comments;

    Future<void> getMoreData() async {
      if (!isMounted() ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      await ref.read(commentsProvider).commentsNextPage(widget.videoId);
    }

    useEffect(
      () {
        controller.addListener(getMoreData);
        return () => controller.removeListener(getMoreData);
      },
      [controller],
    );

    return VideoPopupWrapper(
      isScrollable: false,
      title: currentPage.value == 0
          ? context.locals.comments
          : context.locals.replies,
      onClose: () async {
        if (ref.read(commentsProvider).replyComment != null) {
          await pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          ref.read(commentsProvider).replyComment = null;
          return;
        }
        widget.onClose();
      },
      start: [
        if (currentPage.value == 1)
          AdwHeaderButton(
            onPressed: () {
              pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
              ref.read(commentsProvider).replyComment = null;
            },
            icon: Icon(
              Icons.chevron_left,
              color: context.textTheme.bodyLarge!.color,
            ),
          )
        else
          const SizedBox(),
      ],
      child: PageView.builder(
        onPageChanged: (index) => currentPage.value = index,
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (_, index) => [
          ListView.builder(
            controller: controller,
            padding: const EdgeInsets.all(10),
            itemCount: comments!.length + 1,
            itemBuilder: (ctx, idx) {
              final comment = idx != comments.length ? comments[idx] : null;
              return idx == comments.length
                  ? getCircularProgressIndicator()
                  : BuildCommentBox(
                      comment: comment!,
                      onReplyTap: () {
                        ref.read(commentsProvider).replyComment = comment;
                        pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      },
                      hideReplyBtn: !comment.hasReplies,
                    );
            },
          ),
          RepliesPage(
            videoId: widget.videoId,
            comment: replyComment,
            padding: const EdgeInsets.all(10),
          ),
        ][index],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RepliesPage extends HookConsumerWidget {
  const RepliesPage({
    required this.videoId,
    required this.comment,
    required this.padding,
    super.key,
  });

  final String videoId;
  final CommentData? comment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useScrollController();
    final isMounted = useIsMounted();
    final commentsP = ref.watch(commentsProvider);

    Future<void> getMoreData() async {
      if (!isMounted() ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      await ref.read(commentsProvider).repliesNextPage(videoId);
    }

    Future<void> loadData() async {
      await ref.read(commentsProvider).getReplies(videoId);
    }

    useEffect(
      () {
        loadData();
        controller.addListener(getMoreData);
        return () => controller.removeListener(getMoreData);
      },
      [controller],
    );

    return comment != null
        ? ListView(
            controller: controller,
            padding: padding,
            children: [
              BuildCommentBox(
                comment: comment!,
                onReplyTap: null,
                hideReplyBtn: true,
              ),
              const Divider(),
              if (commentsP.replies != null)
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      for (CommentData reply in commentsP.replies!)
                        BuildCommentBox(
                          comment: reply,
                          onReplyTap: null,
                          hideReplyBtn: true,
                        ),
                      if (commentsP.isLoadingReplies)
                        getCircularProgressIndicator(),
                    ],
                  ),
                )
              else if (commentsP.isLoadingReplies)
                getCircularProgressIndicator()
              else ...[
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'No replies found.',
                  ),
                ),
              ]
            ],
          )
        : getCircularProgressIndicator();
  }
}
