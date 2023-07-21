import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miniplayer/miniplayer.dart';

final miniPlayerControllerProvider = Provider<MiniplayerController>((ref) {
  return MiniplayerController();
});
