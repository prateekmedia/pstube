import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _box = Hive.box('playlist');

final playlistProvider = StateNotifierProvider<PlaylistNotifier, Map<String, List<String>>>(
  (_) =>
      PlaylistNotifier(Map<String, List<String>>.from(_box.get('playlist', defaultValue: {'Watch later': <String>[]}))),
);

class PlaylistNotifier extends StateNotifier<Map<String, List<String>>> {
  PlaylistNotifier(state) : super(state);

  void refresh() {
    state = state;
    _box.put('playlist', state);
  }
}
