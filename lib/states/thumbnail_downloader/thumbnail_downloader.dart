import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/my_prefs.dart';

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
