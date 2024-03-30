import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/services/piped_service.dart';

final videoViewModelProvider = Provider<VideoViewModel>((ref) {
  final pipedService = ref.watch(pipedServiceProvider);
  return VideoViewModel(pipedService);
});

final videoInfoProvider = FutureProvider.autoDispose
    .family<VideoData?, VideoId>((ref, videoId) async {
  final videoViewModel = ref.read(videoViewModelProvider);
  return videoViewModel.getInfo(videoId);
});

class VideoViewModel {
  VideoViewModel(this.pipedService);

  final PipedService pipedService;

  Future<VideoData?> getInfo(VideoId videoId) {
    return pipedService.getVideoData(videoId);
  }
}
