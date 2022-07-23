import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/view_model/video_info_view_model.dart';
import 'package:pstube/ui/screens/video_screen/view_model/comments_view_model.dart';

class VideosChangeNotifier extends ChangeNotifier {
  VideosChangeNotifier(ChangeNotifierProviderRef ref) : _ref = ref;

  final ChangeNotifierProviderRef _ref;
  late final videoViewModel = _ref.read(videoViewModelProvider);

  bool isLoading = true;

  List<VideoData> videos = [];

  Future<void> addVideoUrl(String videoId, VideoData? value) async {
    _ref.read(commentsProvider).resetComments();
    isLoading = true;

    if (value != null) {
      videos.add(
        value,
      );
    }

    final videoData = await videoViewModel.getInfo(VideoId(videoId));

    if (videoData != null) {
      if (value != null) {
        final index = videos.indexWhere(
          (element) => element.id.value == value.id.value,
        );
        videos.replaceRange(
          index,
          index + 1,
          [videoData],
        );
      } else {
        videos.add(
          videoData,
        );
      }
    }

    isLoading = false;
    notifyListeners();
    await _ref.read(commentsProvider).getComments(videos.last.id.value);
  }

  Future<void> addVideoData(
    VideoData videoData, {
    bool loadMore = false,
  }) async {
    _ref.read(commentsProvider).resetComments();
    isLoading = true;
    notifyListeners();
    videos.add(videoData);
    if (loadMore) {
      final videoInfo = await videoViewModel.getInfo(videoData.id);

      if (videoInfo != null) {
        final index = videos.indexWhere(
          (element) => element.id.value == videoData.id.value,
        );
        videos.replaceRange(
          index,
          index + 1,
          [videoInfo],
        );
      }
    }
    isLoading = false;
    notifyListeners();
    await _ref.read(commentsProvider).getComments(videos.last.id.value);
  }

  Future<void> popVideo() async {
    _ref.read(commentsProvider).resetComments();
    videos.removeLast();
    notifyListeners();
    await _ref.read(commentsProvider).getComments(videos.last.id.value);
  }

  void disposeVideos() {
    videos = [];
  }
}
