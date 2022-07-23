import 'package:built_collection/built_collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/comment_data.dart';
import 'package:pstube/data/models/comments_list.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/states/region/provider.dart';

final pipedServiceProvider = Provider<PipedService>((ref) {
  final api = PipedApi().getUnauthenticatedApi();
  return PipedService(api: api, ref: ref);
});
final trendingVideosProvider = FutureProvider((ref) {
  final pipedService = ref.watch(pipedServiceProvider);
  return pipedService.getTrending();
});

class PipedService {
  PipedService({required this.api, required this.ref});

  final Ref ref;
  final UnauthenticatedApi api;

  Future<BuiltList<VideoData>?> getTrending() async {
    final trending = await api.trending(
      region: ref.watch(regionProvider),
    );

    if (trending.data == null) return null;
    final data = trending.data!
        .map(
          VideoData.fromStreamItem,
        )
        .toBuiltList();

    return data;
  }

  Future<VideoData?> getVideoData(VideoId videoId) async {
    final data = (await PipedApi().getUnauthenticatedApi().streamInfo(
              videoId: videoId.value,
            ))
        .data;

    if (data == null) return null;

    return VideoData.fromVideoInfo(
      data,
      videoId,
    );
  }

  Future<CommentsList?>? comments({required String videoId}) async {
    final commentsPage = (await PipedApi().getUnauthenticatedApi().comments(
              videoId: videoId,
            ))
        .data;

    if (commentsPage?.comments == null) return null;

    final _comments = commentsPage!.comments!
        .map(
          CommentData.fromComment,
        )
        .toBuiltList();

    return CommentsList(
      comments: _comments,
      nextpage: commentsPage.nextpage,
    );
  }

  Future<CommentsList?>? commentsNextPage({
    required String videoId,
    required String nextpage,
  }) async {
    final commentsPage =
        (await PipedApi().getUnauthenticatedApi().commentsNextPage(
                  nextpage: nextpage,
                  videoId: videoId,
                ))
            .data;

    if (commentsPage?.comments == null) return null;

    final _comments = commentsPage!.comments!
        .map(
          CommentData.fromComment,
        )
        .toBuiltList();

    return CommentsList(
      comments: _comments,
      nextpage: commentsPage.nextpage,
    );
  }

  Future<SearchPage?> search({
    required String query,
    required SearchFilter filter,
  }) async =>
      (await api.search(
        q: query,
        filter: filter,
      ))
          .data;

  Future<SearchPage?> searchNextPage({
    required String nextpage,
    required String query,
    required SearchFilter filter,
  }) async =>
      (await api.searchNextPage(
        nextpage: nextpage,
        q: query,
        filter: filter,
      ))
          .data;
}
