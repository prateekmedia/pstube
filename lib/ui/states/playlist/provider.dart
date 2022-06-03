import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/ui/states/playlist/playlist.dart';

final playlistProvider = ChangeNotifierProvider((_) => PlaylistNotifier());
