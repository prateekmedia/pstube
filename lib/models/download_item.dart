import 'package:dio/dio.dart';
import 'package:flutube/models/models.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadItem {
  final QueryVideo queryVideo;
  final int downloaded;
  final int total;
  CancelToken? cancelToken;

  DownloadItem({
    required this.queryVideo,
    required this.downloaded,
    this.cancelToken,
    required this.total,
  });

  static DownloadItem fromVideo(
    Video video,
    String path,
    stream, {
    int downloaded = 0,
    int total = 0,
  }) {
    return DownloadItem(
      queryVideo: QueryVideo.fromVideo(video, stream, path),
      downloaded: downloaded,
      total: total,
    );
  }

  DownloadItem copyWith({
    QueryVideo? queryVideo,
    int? downloaded,
    CancelToken? cancelToken,
    int? total,
  }) {
    return DownloadItem(
      queryVideo: queryVideo ?? this.queryVideo,
      downloaded: downloaded ?? this.downloaded,
      total: total ?? this.total,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}
