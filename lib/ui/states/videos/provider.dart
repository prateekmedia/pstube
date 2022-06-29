import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/ui/states/videos/videos_change_notifier.dart';

final videosProvider = ChangeNotifierProvider(
  (_) => VideosChangeNotifier(),
);
