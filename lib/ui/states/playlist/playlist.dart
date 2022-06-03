import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final _box = Hive.box<dynamic>('playlist');

class PlaylistNotifier extends ChangeNotifier {
  PlaylistNotifier() : super();

  Future<void> createPlaylistFromExisting(String id) async {
    final yt = YoutubeExplode();
    final playlist = await yt.playlists.get(id);

    addPlaylist(playlist.title);

    final videos = yt.playlists.getVideos(id);

    await videos.forEach(
      (video) {
        addVideo(playlist.title, video.url);
      },
    );
  }

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
