import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _box = Hive.box<List<dynamic>>('historyList');

class HistoryChangeNotifier extends ChangeNotifier {
  HistoryChangeNotifier() {
    init();
  }
  late List<String> history;

  void init() {
    history = _box.get('history', defaultValue: <String>[])!.cast<String>();
  }

  void addSearchedTerm(String term) {
    if (term.isEmpty) return;

    if (history.contains(term)) {
      history.remove(term);
    }

    if (history.length >= 15) {
      history.removeLast();
    }

    history.insert(0, term);
    _box.put('history', history);
  }
}
