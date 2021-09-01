import 'package:equatable/equatable.dart';
import 'package:flutube/utils/int_extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class QueryVideo extends Equatable {
  final String name;
  final String id;
  final String path;
  final String author;
  final Duration duration;
  final String thumbnail;
  final String quality;
  final String url;

  const QueryVideo({
    required this.name,
    required this.id,
    required this.path,
    required this.url,
    required this.author,
    required this.quality,
    required this.duration,
    required this.thumbnail,
  });

  static QueryVideo fromVideo({
    required Video video,
    required stream,
    required String path,
  }) {
    return QueryVideo(
      name: video.title +
          '(' +
          (stream is AudioOnlyStreamInfo
              ? stream.bitrate.bitsPerSecond.getBitrate()
              : '${stream.videoResolution.width}x${stream.videoResolution.height}') +
          ')' +
          (stream is MuxedStreamInfo ? '.' + stream.container.name : '.m4a'),
      id: video.id.value,
      path: path,
      url: stream.url.toString(),
      author: video.author,
      quality: stream is AudioOnlyStreamInfo
          ? stream.bitrate.bitsPerSecond.getBitrate()
          : '${stream.videoResolution.width}x${stream.videoResolution.height}',
      duration: video.duration ?? const Duration(seconds: 0),
      thumbnail: video.thumbnails.lowResUrl,
    );
  }

  @override
  List<Object?> get props => [name, id, quality, path];
}
