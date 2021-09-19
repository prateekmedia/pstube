import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _box = Hive.box('playlist');

final playlistProvider = StateNotifierProvider<PlaylistNotifier, Map<String, List<String>>>(
  (_) =>
      PlaylistNotifier(Map<String, List<String>>.from(_box.get('playlist', defaultValue: {'Watch later': <String>[]}))),
);

class PlaylistNotifier extends StateNotifier<Map<String, List<String>>> {
  PlaylistNotifier(state) : super(state);

  bool validatePlaylist(String playlist) => playlist.isNotEmpty;

  void removePlaylist(String playlist, [bool re = true]) {
    state.remove(playlist);
    if (re) {
      refresh();
    }
  }

  void addPlaylist(String playlist, [bool re = true]) {
    if (validatePlaylist(playlist)) {
      state.putIfAbsent(playlist, () => []);
      if (re) {
        refresh();
      }
    }
  }

  void addVideo(String playlist, String videoUrl) {
    if (validatePlaylist(playlist)) {
      addPlaylist(playlist, false);
      if (state.containsKey(playlist)) {
        state.entries
            .firstWhere((entry) => entry.key == playlist && !entry.value.contains(videoUrl))
            .value
            .add(videoUrl);
      }
      refresh();
    }
  }

  void removeVideo(String playlist, String videoUrl) {
    if (validatePlaylist(playlist) && state.containsKey(playlist)) {
      state.entries
          .firstWhere((entry) => entry.key == playlist && entry.value.contains(videoUrl))
          .value
          .remove(videoUrl);

      refresh();
    }
  }

  void refresh() {
    state = state;
    _box.put('playlist', state);
  }
}
