import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/states/thumbnail_downloader/thumbnail_downloader.dart';

final thumbnailDownloaderProvider =
    StateNotifierProvider<ThumbnailDownloaderNotifier, bool>(
  (_) => ThumbnailDownloaderNotifier(
    state: MyPrefs().prefs.getBool('thumbnailDownloader') ?? false,
  ),
);
