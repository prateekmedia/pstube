import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/states/download_path/download_path.dart';

final downloadPathProvider =
    ChangeNotifierProvider((_) => DownloadPathNotifier());
