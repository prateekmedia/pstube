import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/comment_data.dart';
import 'package:pstube/data/models/comments_list.dart';
import 'package:pstube/foundation/services/piped_service.dart';

final commentsProvider =
    ChangeNotifierProvider<CommentsNotifierProvider>((ref) {
  final api = ref.watch(pipedServiceProvider);
  return CommentsNotifierProvider(ref, api);
});

class CommentsNotifierProvider extends ChangeNotifier {
  CommentsNotifierProvider(this.ref, this.api);

  final Ref ref;
  final PipedService api;

  bool isLoadingReplies = true;
  CommentData? _replyComment;
  CommentData? get replyComment => _replyComment;

  set replyComment(CommentData? newReplyComment) {
    _replyComment = newReplyComment;
    if (_replyComment == null) {
      _repliesList = null;
    }
    notifyListeners();
  }

  bool isLoading = true;
  CommentsList? _repliesList;
  BuiltList<CommentData>? get replies => _repliesList?.comments;

  CommentsList? _commentsList;
  BuiltList<CommentData>? get comments => _commentsList?.comments;

  void resetComments() {
    _commentsList = null;
    notifyListeners();
  }

  Future<void> getComments(String videoId) async {
    isLoading = true;
    _commentsList = null;
    if (!isLoading) {
      notifyListeners();
    }
    final page = await api.comments(
      videoId: videoId,
    );

    if (page?.comments == null) return;

    _commentsList = page;
    isLoading = false;
    notifyListeners();
  }

  Future<void> commentsNextPage(String videoId) async {
    if (_commentsList?.nextpage == null || isLoading) return;

    isLoading = true;
    notifyListeners();

    final nextPage = await api.commentsNextPage(
      nextpage: _commentsList!.nextpage!,
      videoId: videoId,
    );

    if (nextPage?.comments == null) {
      return;
    }

    _commentsList = _commentsList!.rebuild(nextPage!.comments);
    isLoading = false;
    notifyListeners();
  }

  Future<void> getReplies(String videoId) async {
    isLoadingReplies = true;
    _repliesList = null;
    notifyListeners();

    final page = await api.comments(
      videoId: videoId,
    );

    if (page?.comments == null) return;

    _repliesList = page;
    isLoadingReplies = false;
    notifyListeners();
  }

  Future<void> repliesNextPage(String videoId) async {
    if (_repliesList?.nextpage == null || isLoadingReplies) {
      return;
    }

    isLoadingReplies = true;
    notifyListeners();

    final nextPage = await api.commentsNextPage(
      nextpage: _repliesList!.nextpage!,
      videoId: videoId,
    );

    if (nextPage?.comments == null) {
      return;
    }

    _commentsList = _repliesList!.rebuild(nextPage!.comments);
    isLoadingReplies = false;
    notifyListeners();
  }
}
