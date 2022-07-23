import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/video_data.dart';
import 'package:pstube/foundation/services/piped_service.dart';

final videoViewModelProvider = Provider<VideoViewModel>((ref) {
  final pipedService = ref.watch(pipedServiceProvider);
  return VideoViewModel(pipedService);
});

FutureProvider<VideoData?> videoInfoProvider(String videoUrl) =>
    FutureProvider((ref) async {
      final videoViewModel = ref.watch(videoViewModelProvider);
      return videoViewModel.getInfo(videoUrl);
    });

class VideoViewModel {
  VideoViewModel(this.pipedService);

  final PipedService pipedService;

  Future<VideoData?> getInfo(String videoUrl) =>
      pipedService.getVideoData(videoUrl);
}
