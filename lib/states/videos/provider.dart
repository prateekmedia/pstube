import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/states/videos/videos_change_notifier.dart';

final videosProvider = ChangeNotifierProvider(
  VideosChangeNotifier.new,
);
