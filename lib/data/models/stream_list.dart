import 'package:built_collection/built_collection.dart';

class StreamList<T> {
  StreamList({
    required this.streams,
    required String? nextpage,
  }) : _nextpage = nextpage;

  final BuiltList<T> streams;
  final String? _nextpage;

  bool get hasNextpage => _nextpage != null;
  String? get nextpage => _nextpage;

  StreamList<T> rebuild(BuiltList<T> nextPage) {
    return StreamList(
      nextpage: _nextpage,
      streams: streams.rebuild(
        (b) => b.addAll(
          nextPage.toList(),
        ),
      ),
    );
  }
}
