import 'package:flutter/widgets.dart';
import 'package:flutube/models/models.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final likedListProvider = ChangeNotifierProvider((ref) => LikedList(ref));

final _box = Hive.box('likedList');

class LikedList extends ChangeNotifier {
  final ChangeNotifierProviderRef ref;
  LikedList(this.ref);

  List likedVideoList = _box.get('likedVideoList', defaultValue: []);
  List likedCommentList = _box.get('likedCommentList', defaultValue: []);

  addVideo(String url) {
    if (!likedVideoList.contains(url)) {
      likedVideoList.add(url);
      refresh(true);
    }
  }

  removeVideo(String url) {
    if (likedVideoList.contains(url)) {
      likedVideoList.remove(url);
      refresh(true);
    }
  }

  addComment(LikedComment comment) {
    if (likedCommentList
        .where((element) =>
            (element.author == comment.author) &&
            (element.text == comment.text))
        .isEmpty) {
      likedCommentList.add(comment);
      refresh(false);
    }
  }

  removeComment(LikedComment comment) {
    if (likedCommentList.contains(comment)) {
      likedCommentList.remove(comment);
      refresh(false);
    }
  }

  refresh([bool? value]) {
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
