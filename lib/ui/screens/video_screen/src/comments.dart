import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/video_screen/src/build_comment_box.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class CommentsWidget extends StatefulHookWidget {
  const CommentsWidget({
    super.key,
    this.onClose,
    required this.videoId,
    required this.replyComment,
    required this.snapshot,
  });

  final String videoId;
  final ValueNotifier<Comment?> replyComment;
  final AsyncSnapshot<Response<CommentsPage>?> snapshot;
  final VoidCallback? onClose;

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isMounted = useIsMounted();
    final pageController = PageController();
    final _currentPage = useState<BuiltList<Comment>?>(
      widget.snapshot.data?.data?.comments,
    );
    final controller = useScrollController();
    final currentPage = useState<int>(0);
    final nextPageToken = useState<String?>(
      widget.snapshot.data?.data?.nextpage,
    );
    final isLoading = useState<bool>(false);

    Future<void> _getMoreData() async {
      if (isLoading.value ||
          !isMounted() ||
          _currentPage.value == null ||
          nextPageToken.value == null ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      isLoading.value = true;

      final nextPage =
          await PipedApi().getUnauthenticatedApi().commentsNextPage(
                videoId: widget.videoId,
                nextpage: nextPageToken.value!,
              );

      if (nextPage.data == null && nextPage.data!.comments == null) {
        return;
      }

      nextPageToken.value = nextPage.data!.nextpage;

      _currentPage.value = _currentPage.value!.rebuild(
        (b) => b.addAll(
          nextPage.data!.comments!.toList(),
        ),
      );
      isLoading.value = false;
    }

    useEffect(
      () {
        controller.addListener(_getMoreData);
        return () => controller.removeListener(_getMoreData);
      },
      [controller],
    );

    return Column(
      children: [
        AdwHeaderBar(
          title: Text(
            currentPage.value == 0
                ? context.locals.comments
                : context.locals.replies,
          ),
          actions: AdwActions(
            onClose: widget.onClose ?? context.back,
            onHeaderDrag: appWindow?.startDragging,
            onDoubleTap: appWindow?.maximizeOrRestore,
          ),
          style: const HeaderBarStyle(
            autoPositionWindowButtons: false,
            height: 46,
          ),
          start: [
            if (currentPage.value == 1)
              AdwHeaderButton(
                onPressed: () {
                  pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                  widget.replyComment.value = null;
                },
                icon: Icon(
                  Icons.chevron_left,
                  color: context.textTheme.bodyText1!.color,
                ),
              )
            else
              const SizedBox(),
          ],
        ),
        Expanded(
          child: ColoredBox(
            color: context.theme.canvasColor,
            child: WillPopScope(
              child: PageView.builder(
                onPageChanged: (index) => currentPage.value = index,
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (_, index) => [
                  ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _currentPage.value!.length + 1,
                    itemBuilder: (ctx, idx) {
                      final comment = idx != _currentPage.value!.length
                          ? _currentPage.value![idx]
                          : null;
                      return idx == _currentPage.value!.length
                          ? getCircularProgressIndicator()
                          : BuildCommentBox(
                              comment: comment!,
                              onReplyTap: () {
                                widget.replyComment.value = comment;
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              },
                              hideReplyBtn: comment.repliesPage == null,
                            );
                    },
                  ),
                  RepliesPage(
                    videoId: widget.videoId,
                    comment: widget.replyComment.value,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.onClose != null ? 16 : 0,
                    ),
                  ),
                ][index],
              ),
              onWillPop: () async {
                if (widget.replyComment.value != null) {
                  await pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                  widget.replyComment.value = null;
                } else {
                  context.back();
                }
                return false;
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RepliesPage extends HookWidget {
  const RepliesPage({
    super.key,
    required this.videoId,
    required this.comment,
    required this.padding,
  });

  final String videoId;
  final Comment? comment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final _currentPage = useState<BuiltList<Comment>?>(null);
    final controller = useScrollController();
    final repliesToken = useState<String?>(
      comment?.repliesPage,
    );
    final isLoading = useState<bool>(true);
    final isMounted = useIsMounted();

    Future<void> _getMoreData() async {
      if (isLoading.value ||
          !isMounted() ||
          _currentPage.value == null ||
          repliesToken.value == null ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      isLoading.value = true;

      final nextPage =
          await PipedApi().getUnauthenticatedApi().commentsNextPage(
                videoId: videoId,
                nextpage: repliesToken.value!,
              );

      if (nextPage.data == null && nextPage.data!.comments == null) {
        return;
      }

      repliesToken.value = nextPage.data!.nextpage;

      _currentPage.value = _currentPage.value!.rebuild(
        (b) => b.addAll(
          nextPage.data!.comments!.toList(),
        ),
      );
      isLoading.value = false;
    }

    Future<void> loadData() async {
      if (repliesToken.value == null) {
        isLoading.value = false;
        return;
      }
      final nextPage =
          await PipedApi().getUnauthenticatedApi().commentsNextPage(
                videoId: videoId,
                nextpage: repliesToken.value!,
              );
      if (nextPage.data == null) return;

      _currentPage.value = nextPage.data!.comments;
      isLoading.value = false;
    }

    useEffect(
      () {
        loadData();
        controller.addListener(_getMoreData);
        return () => controller.removeListener(_getMoreData);
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
              if (_currentPage.value != null)
                Container(
                  padding: const EdgeInsets.only(left: 50),
                  child: Column(
                    children: [
                      for (Comment reply in _currentPage.value!)
                        BuildCommentBox(
                          comment: reply,
                          onReplyTap: null,
                          hideReplyBtn: true,
                        ),
                      if (repliesToken.value != null)
                        getCircularProgressIndicator(),
                    ],
                  ),
                )
              else if (isLoading.value)
                getCircularProgressIndicator()
              else
                const Center(
                  child: IconWithLabel(
                    label: 'No replies found.',
                  ),
                ),
            ],
          )
        : getCircularProgressIndicator();
  }
}
