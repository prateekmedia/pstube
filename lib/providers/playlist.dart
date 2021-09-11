import 'package:hooks_riverpod/hooks_riverpod.dart';

final playlistProvider = StateNotifierProvider<PlaylistNotifier, Map<String, List<String>>>(
  (_) => PlaylistNotifier({'Watch later': []}),
);

class PlaylistNotifier extends StateNotifier<Map<String, List<String>>> {
  PlaylistNotifier(state) : super(state);
}
