import 'package:flutter/widgets.dart';
import 'package:flutube/models/models.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final likedListProvider = ChangeNotifierProvider((ref) => LikedList(ref));

final box = Hive.box('likedList');

class LikedList extends ChangeNotifier {
  final ProviderRefBase ref;
  LikedList(this.ref);

  List likedVideoList = box.get('likedVideoList', defaultValue: []);
  List likedCommentList = box.get('likedCommentList', defaultValue: []);

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
    if (!likedCommentList.contains(comment)) {
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
        box.put('likedVideoList', likedVideoList);
      } else {
        box.put('likedCommentList', likedCommentList);
      }
    }
  }
}
