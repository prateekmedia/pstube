import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutube/utils/utils.dart';

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
  List<ThumbnailStreamInfo> toStreamInfo(BuildContext context) => [
        ThumbnailStreamInfo(
          name: context.locals.lowResolution,
          url: lowResUrl,
        ),
        ThumbnailStreamInfo(
          name: context.locals.mediumResolution,
          url: mediumResUrl,
        ),
        ThumbnailStreamInfo(
          name: context.locals.standardResolution,
          url: standardResUrl,
        ),
        ThumbnailStreamInfo(
          name: context.locals.highResolution,
          url: highResUrl,
        ),
        ThumbnailStreamInfo(
          name: context.locals.maxResolution,
          url: maxResUrl,
        ),
      ];
}
