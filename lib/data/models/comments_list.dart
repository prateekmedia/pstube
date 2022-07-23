import 'package:built_collection/built_collection.dart';
import 'package:pstube/data/models/comment_data.dart';

class CommentsList {
  CommentsList({
    required this.comments,
    required this.nextpage,
  });

  final BuiltList<CommentData> comments;
  final String? nextpage;

  CommentsList rebuild(BuiltList<CommentData> nextPage) {
    return CommentsList(
      nextpage: nextpage,
      comments: comments.rebuild(
        (b) => b.addAll(
          nextPage.toList(),
        ),
      ),
    );
  }
}
