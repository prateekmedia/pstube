import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/states/playlist/playlist.dart';

final playlistProvider = ChangeNotifierProvider((_) => PlaylistNotifier());
