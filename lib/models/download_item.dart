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

  static DownloadItem fromVideo({
    required Video video,
    required stream,
    required String path,
    int downloaded = 0,
    int total = 0,
  }) {
    return DownloadItem(
      queryVideo: QueryVideo.fromVideo(
        video: video,
        stream: stream,
        path: path,
      ),
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
