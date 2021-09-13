import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ThumbnailStreamInfo {
  final String name;
  final String url;
  final String containerName;

  ThumbnailStreamInfo({
    required this.name,
    required this.url,
    this.containerName = "jpg",
  });
}

extension CreateThumbnailStreamInfo on ThumbnailSet {
  List<ThumbnailStreamInfo> get toStreamInfo => [
        ThumbnailStreamInfo(name: "Low resolution", url: lowResUrl),
        ThumbnailStreamInfo(name: "Medium resolution", url: mediumResUrl),
        ThumbnailStreamInfo(name: "Standard resolution", url: standardResUrl),
        ThumbnailStreamInfo(name: "High resolution", url: highResUrl),
        ThumbnailStreamInfo(name: "Max resolution", url: maxResUrl),
      ];
}
