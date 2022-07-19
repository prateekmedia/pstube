import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/states/history/history_change_notifier.dart';

final historyProvider = ChangeNotifierProvider((ref) {
  return HistoryChangeNotifier();
});
