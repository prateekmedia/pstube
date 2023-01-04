import 'package:built_collection/built_collection.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/models.dart';

class VideoData {
  VideoData({
    required this.thumbnails,
    required this.title,
    required this.id,
    this.duration,
    this.durationString,
    this.uploaded,
    this.uploadDate,
    this.uploaderAvatar,
    this.uploader,
    this.uploaderId,
    this.uploaderVerified,
    this.views,
    this.relatedStreams,
    this.audioStreams,
    this.videoStreams,
    this.description,
    this.likes,
  });

  VideoData.fromStreamItem(StreamItem streamItem)
      : durationString = null,
        duration = streamItem.duration,
        thumbnails = Thumbnails(videoId: streamItem.url),
        title = streamItem.title,
        id = VideoId(streamItem.url),
        relatedStreams = null, // streamItem.relatedStreams,
        views = streamItem.views,
        audioStreams = null, // streamItem.audioStreams,
        videoStreams = null, // streamItem.videoStreams,
        uploaded = streamItem.uploaded,
        uploadDate = streamItem.uploadedDate,
        uploaderAvatar = streamItem.uploaderAvatar,
        uploader = streamItem.uploaderName,
        uploaderId = streamItem.uploaderUrl != null
            ? UploaderId.addPrefix(streamItem.uploaderUrl!)
            : null,
        uploaderVerified = streamItem.uploaderVerified,
        description = null, //streamItem.description,
        likes = 0;

  VideoData.fromVideoInfo(
    VideoInfo videoInfo,
    VideoId videoId,
  )   : durationString = null,
        duration = videoInfo.duration,
        thumbnails = Thumbnails(videoId: videoId.value),
        title = videoInfo.title,
        id = videoId,
        relatedStreams = videoInfo.relatedStreams,
        views = videoInfo.views,
        audioStreams = videoInfo.audioStreams,
        videoStreams = videoInfo.videoStreams,
        uploaded = null,
        uploadDate = videoInfo.uploadDate,
        uploaderAvatar = videoInfo.uploaderAvatar,
        uploader = videoInfo.uploader,
        uploaderId = videoInfo.uploaderUrl != null
            ? UploaderId.addPrefix(videoInfo.uploaderUrl!)
            : null,
        uploaderVerified = videoInfo.uploaderVerified,
        description = videoInfo.description,
        likes = videoInfo.likes;

  final BuiltList<StreamItem>? relatedStreams;

  /// The duration of the video in seconds.
  final int? duration;

  /// The duration of the video in HH:MM:SS format
  final String? durationString;

  /// The thumbnail of the video.
  final Thumbnails thumbnails;

  /// The title of the video.
  final String? title;

  /// The date in unix epoch the video was uploaded.
  final int? uploaded;

  /// The relative date the video was uploaded on.
  final String? uploadDate;

  /// The avatar of the channel of the video.
  final String? uploaderAvatar;

  /// The name of the channel of the video.
  final String? uploader;

  /// The relative URL of the channel of the video.
  final UploaderId? uploaderId;

  /// Whether or not the channel has a verified badge.
  final bool? uploaderVerified;

  /// The id of the video.
  final VideoId id;

  /// The number of views the video has.
  final int? views;

  /// The description of the video
  final String? description;

  /// The likes of the video
  final int? likes;

  final BuiltList<Stream>? audioStreams;

  final BuiltList<Stream>? videoStreams;
}
