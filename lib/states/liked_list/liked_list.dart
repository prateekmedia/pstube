import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/models.dart';

final _box = Hive.box<List<dynamic>>('likedList');

class LikedList extends ChangeNotifier {
  LikedList(this.ref);
  final ChangeNotifierProviderRef ref;

  List<dynamic> likedVideoList =
      _box.get('likedVideoList', defaultValue: <dynamic>[])!;
  List<dynamic> likedCommentList =
      _box.get('likedCommentList', defaultValue: <dynamic>[])!;

  void addVideo(String url) {
    if (!likedVideoList.contains(url)) {
      likedVideoList.add(url);
      refresh(value: true);
    }
  }

  void removeVideo(String url) {
    if (likedVideoList.contains(url)) {
      likedVideoList.remove(url);
      refresh(value: true);
    }
  }

  void addComment(LikedComment comment) {
    if (likedCommentList
        .where(
          (dynamic element) =>
              (element.author == comment.author) &&
              (element.commentText == comment.text),
        )
        .isEmpty) {
      likedCommentList.add(comment);
      refresh(value: false);
    }
  }

  void removeComment(LikedComment comment) {
    if (likedCommentList.contains(comment)) {
      likedCommentList.remove(comment);
      refresh(value: false);
    }
  }

  void refresh({bool? value}) {
    notifyListeners();
    if (value != null) {
      if (value) {
        _box.put('likedVideoList', likedVideoList);
      } else {
        _box.put('likedCommentList', likedCommentList);
      }
    }
  }
}
