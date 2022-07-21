import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/my_prefs.dart';

final playerStateProvider =
    ChangeNotifierProvider.autoDispose<PlayerStateNotifier>((ref) {
  return PlayerStateNotifier();
});

class PlayerStateNotifier extends ChangeNotifier {
  PlayerStateNotifier() {
    init();
  }
  PlaylistMode _playlistMode = PlaylistMode.single;
  BoxFit _boxFit = BoxFit.fitHeight;

  PlaylistMode get playlistMode => _playlistMode;
  BoxFit get boxFit => _boxFit;

  set playlistMode(PlaylistMode newPlaylistMode) {
    MyPrefs().prefs.setString('playlistMode', newPlaylistMode.name);
    _playlistMode = newPlaylistMode;
    notifyListeners();
  }

  set boxFit(BoxFit newBoxFit) {
    MyPrefs().prefs.setString('boxFit', newBoxFit.name);
    _boxFit = newBoxFit;
    notifyListeners();
  }

  void init() {
    final playMode = PlaylistMode.values.where(
      (element) => element.name == MyPrefs().prefs.getString('playlistMode'),
    );
    if (playMode.isNotEmpty) {
      _playlistMode = playMode.first;
    }
    final boxFit = BoxFit.values.where(
      (element) => element.name == MyPrefs().prefs.getString('boxFit'),
    );
    if (boxFit.isNotEmpty) {
      _boxFit = boxFit.first;
    }
  }
}
