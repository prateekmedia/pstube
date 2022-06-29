import 'package:flutter/cupertino.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/models.dart';

class VideosChangeNotifier extends ChangeNotifier {
  final _api = PipedApi().getUnauthenticatedApi();
  bool isLoading = true;

  List<VideoData> videos = [];

  Future<void> addVideoUrl(String videoId, VideoData? value) async {
    isLoading = true;
    notifyListeners();

    if (value != null) {
      videos.add(
        value,
      );
    }

    final videoInfo = await _api.streamInfo(
      videoId: videoId,
    );

    if (videoInfo.data != null) {
      if (value != null) {
        final index = videos.indexWhere(
          (element) => element.id.value == value.id.value,
        );
        videos.replaceRange(
          index,
          index + 1,
          [
            VideoData.fromVideoInfo(
              videoInfo.data!,
              VideoId(value.id.value),
            )
          ],
        );
      } else {
        videos.add(
          VideoData.fromVideoInfo(
            videoInfo.data!,
            VideoId(videoId),
          ),
        );
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addVideoData(
    VideoData videoData, {
    bool loadMore = false,
  }) async {
    isLoading = true;
    notifyListeners();
    videos.add(videoData);
    if (loadMore) {
      final videoInfo = await _api.streamInfo(
        videoId: videoData.id.value,
      );

      if (videoInfo.data != null) {
        final index = videos.indexWhere(
          (element) => element.id.value == videoData.id.value,
        );
        videos.replaceRange(
          index,
          index + 1,
          [
            VideoData.fromVideoInfo(
              videoInfo.data!,
              VideoId(videoData.id.value),
            )
          ],
        );
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void popVideo() {
    videos.removeLast();
    notifyListeners();
  }

  void disposeVideos() {
    videos = [];
    notifyListeners();
  }
}
