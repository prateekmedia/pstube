import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final likedListProvider = ChangeNotifierProvider((ref) => LikedList(ref));

class LikedList extends ChangeNotifier {
  final ProviderRefBase ref;
  LikedList(this.ref);

  List<String> likedVideoList = [];
  List<Comment> likedCommentList = [];

  addVideo(String url) {
    if (!likedVideoList.contains(url)) {
      likedVideoList.add(url);
      refresh();
    }
  }

  removeVideo(String url) {
    if (likedVideoList.contains(url)) {
      likedVideoList.remove(url);
      refresh();
    }
  }

  addComment(Comment comment) {
    if (!likedCommentList.contains(comment)) {
      likedCommentList.add(comment);
      refresh();
    }
  }

  removeComment(Comment comemnt) {
    if (likedCommentList.contains(comemnt)) {
      likedCommentList.remove(comemnt);
      refresh();
    }
  }

  refresh() => notifyListeners();
}
