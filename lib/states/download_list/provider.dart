import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/states/download_list/download_list.dart';

final downloadListProvider = ChangeNotifierProvider(DownloadList.new);
