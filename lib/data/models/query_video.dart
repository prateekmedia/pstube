import 'package:hive_flutter/hive_flutter.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/services/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'query_video.g.dart';

@HiveType(typeId: 1)
class QueryVideo {
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
  QueryVideo.fromVideo({
    required Video video,
    required dynamic stream,
    required this.path,
  })  : name = checkIfExists(
          path,
          '${video.title}(${stream is ThumbnailStreamInfo ? stream.name : stream is AudioOnlyStreamInfo ? stream.bitrate.bitsPerSecond.getBitrate() : '${stream.videoResolution.width}x'
              '${stream.videoResolution.height}'}).'
          '${stream is ThumbnailStreamInfo ? stream.containerName : stream is AudioOnlyStreamInfo ? stream.audioCodec.split('.')[0].replaceAll('mp4a', 'm4a') : stream.container.name as String}',
        ),
        id = video.id.value,
        url = stream.url.toString(),
        author = video.author,
        quality = stream is ThumbnailStreamInfo
            ? stream.name
            : stream is AudioOnlyStreamInfo
                ? stream.bitrate.bitsPerSecond.getBitrate()
                : '${stream.videoResolution.width}x'
                    '${stream.videoResolution.height}',
        duration = (video.duration ?? Duration.zero).toString(),
        thumbnail = video.thumbnails.lowResUrl;

  factory QueryVideo.fromJson(Map<String, String> json) => QueryVideo(
        name: json['name']!,
        id: json['id']!,
        path: json['path']!,
        url: json['url']!,
        author: json['author']!,
        duration: json['duration']!,
        quality: json['quality']!,
        thumbnail: json['thumbnail']!,
      );

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final String path;

  @HiveField(3)
  final String author;

  @HiveField(4)
  final String duration;

  @HiveField(5)
  final String thumbnail;

  @HiveField(6)
  final String quality;

  @HiveField(7)
  final String url;

  Map<String, dynamic> toJson() => <String, String>{
        'name': name,
        'id': id,
        'path': path,
        'url': url,
        'author': author,
        'duration': duration,
        'quality': quality,
        'thumbnail': thumbnail,
      };
}
