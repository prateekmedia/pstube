class Thumbnails {
  Thumbnails({
    required String videoId,
  }) : videoId = videoId.startsWith('/watch')
            ? videoId.replaceAll('/watch?v=', '')
            : videoId;

  final String videoId;

  /// Low resolution thumbnail URL.
  String get lowResUrl => 'https://img.youtube.com/vi/$videoId/default.jpg';

  /// Medium resolution thumbnail URL.
  String get mediumResUrl =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

  /// High resolution thumbnail URL.
  String get highResUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  /// Standard resolution thumbnail URL.
  /// Not always available.
  String get standardResUrl =>
      'https://img.youtube.com/vi/$videoId/sddefault.jpg';

  /// Max resolution thumbnail URL.
  /// Not always available.
  String get maxResUrl =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
}
