import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/thumbnail_downloader/thumbnail_downloader.dart';

final thumbnailDownloaderProvider =
    StateNotifierProvider<ThumbnailDownloaderNotifier, bool>(
  (_) => ThumbnailDownloaderNotifier(
    state: MyPrefs().prefs.getBool('thumbnailDownloader') ?? false,
  ),
);
