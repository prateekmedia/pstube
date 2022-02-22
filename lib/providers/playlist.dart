import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _box = Hive.box<dynamic>('playlist');

final playlistProvider = ChangeNotifierProvider((_) => PlaylistNotifier());

class PlaylistNotifier extends ChangeNotifier {
  PlaylistNotifier() : super();

  Map<String, List<String>> playlist = Map<String, List<String>>.from(
    _box.get('playlist', defaultValue: {'Watch later': <String>[]}) as Map,
  );

  bool validatePlaylist(String playlist) => playlist.isNotEmpty;

  void removePlaylist(String plist) {
    playlist.remove(plist);
    refresh();
  }

  void addPlaylist(String plist, {bool re = true}) {
    if (validatePlaylist(plist)) {
      playlist.putIfAbsent(plist, () => []);
      if (re) {
        refresh();
      }
    }
  }

  void addVideo(String plist, String videoUrl) {
    if (validatePlaylist(plist)) {
      addPlaylist(plist, re: false);
      if (playlist.containsKey(plist)) {
        playlist.entries
            .firstWhere(
              (entry) => entry.key == plist && !entry.value.contains(videoUrl),
            )
            .value
            .add(videoUrl);
      }
      refresh();
    }
  }

  void removeVideo(String plist, String videoUrl) {
    if (validatePlaylist(plist) && playlist.containsKey(plist)) {
      playlist.entries
          .firstWhere(
            (entry) => entry.key == plist && entry.value.contains(videoUrl),
          )
          .value
          .remove(videoUrl);
    }
    refresh();
  }

  void refresh() {
    _box.put('playlist', playlist);
    notifyListeners();
  }
}
