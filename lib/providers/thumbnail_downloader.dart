import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sftube/utils/shared_prefs.dart';

final thumbnailDownloaderProvider =
    StateNotifierProvider<ThumbnailDownloaderNotifier, bool>(
  (_) => ThumbnailDownloaderNotifier(
    state: MyPrefs().prefs.getBool('thumbnailDownloader') ?? false,
  ),
);

class ThumbnailDownloaderNotifier extends StateNotifier<bool> {
  ThumbnailDownloaderNotifier({required bool state}) : super(state);

  set value(bool value) {
    state = value;
    MyPrefs().prefs.setBool('thumbnailDownloader', state);
  }

  void reset() {
    MyPrefs()
        .prefs
        .remove('thumbnailDownloader')
        .whenComplete(() => state = false);
  }
}
