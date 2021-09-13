import 'package:flutube/utils/shared_prefs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final thumbnailDownloaderProvider = StateNotifierProvider<ThumbnailDownloaderNotifier, bool>(
  (_) => ThumbnailDownloaderNotifier(
    MyPrefs().prefs.getBool('thumbnailDownloader') ?? false,
  ),
);

class ThumbnailDownloaderNotifier extends StateNotifier<bool> {
  ThumbnailDownloaderNotifier(state) : super(state);

  set value(bool value) {
    state = value;
    MyPrefs().prefs.setBool('thumbnailDownloader', state);
  }

  reset() {
    MyPrefs().prefs.remove('thumbnailDownloader').whenComplete(() => state = false);
  }
}
