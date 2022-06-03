import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/ui/states/download_path/download_path.dart';

final downloadPathProvider =
    ChangeNotifierProvider((_) => DownloadPathNotifier());
