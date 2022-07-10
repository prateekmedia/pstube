import 'package:dio/dio.dart';
import 'package:pstube/data/models/models.dart';

class DownloadItem {
  DownloadItem({
    required this.queryVideo,
    required this.downloaded,
    this.cancelToken,
    required this.total,
  });

  DownloadItem.fromVideo({
    required VideoData video,
    required StreamData stream,
    required String path,
    this.downloaded = 0,
    this.total = 0,
  }) : queryVideo = QueryVideo.fromVideo(
          video: video,
          stream: stream,
          path: path,
        );

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        downloaded: json['downloaded'] as int,
        total: json['total'] as int,
        queryVideo:
            QueryVideo.fromJson(json['queryVideo'] as Map<String, String>),
      );

  final QueryVideo queryVideo;
  final int downloaded;
  final int total;
  CancelToken? cancelToken;

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'downloaded': downloaded,
        'total': total,
        'queryVideo': queryVideo.toJson(),
      };
}
