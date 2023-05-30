import 'package:built_collection/built_collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/channel_data.dart';
import 'package:pstube/data/models/comment_data.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/models/search_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
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

  Future<ChannelData?> channelInfo(UploaderId uploaderId) async {
    final info = await api.channelInfoId(channelId: uploaderId.value);
    if (info.data == null) return null;
    return ChannelData.fromChannelInfo(channelInfo: info.data!);
  }

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

  Future<StreamList<VideoData>?>? channelNextPage({
    required UploaderId uploaderId,
    required String nextpage,
  }) async {
    final commentsPage = (await api.channelNextPage(
      nextpage: nextpage,
      channelId: uploaderId.value,
    ))
        .data;

    if (commentsPage?.relatedStreams == null) return null;

    final comments = commentsPage!.relatedStreams!
        .map(
          VideoData.fromStreamItem,
        )
        .toBuiltList();

    return StreamList(
      streams: comments,
      nextpage: commentsPage.nextpage,
    );
  }

  Future<VideoData?> getVideoData(VideoId videoId) async {
    final data = (await api.streamInfo(
      videoId: videoId.value,
    ))
        .data;

    if (data == null) return null;

    return VideoData.fromVideoInfo(
      data,
      videoId,
    );
  }

  Future<StreamList<CommentData>?>? comments({required String videoId}) async {
    final commentsPage = (await api.comments(
      videoId: videoId,
    ))
        .data;

    if (commentsPage?.comments == null) return null;

    final comments = commentsPage!.comments!
        .map(
          CommentData.fromComment,
        )
        .toBuiltList();

    return StreamList(
      streams: comments,
      nextpage: commentsPage.nextpage,
    );
  }

  Future<StreamList<CommentData>?>? commentsNextPage({
    required String videoId,
    required String nextpage,
  }) async {
    final commentsPage = (await api.commentsNextPage(
      nextpage: nextpage,
      videoId: videoId,
    ))
        .data;

    if (commentsPage?.comments == null) return null;

    final comments = commentsPage!.comments!
        .map(
          CommentData.fromComment,
        )
        .toBuiltList();

    return StreamList(
      streams: comments,
      nextpage: commentsPage.nextpage,
    );
  }

  Future<StreamList<SearchData>?> search({
    required String query,
    required SearchFilter filter,
  }) async {
    final data = (await api.search(
      q: query,
      filter: filter,
    ))
        .data;

    if (data == null) return null;

    final results =
        data.items!.map((e) => SearchData(data: e.data)).toBuiltList();

    return StreamList(
      streams: results,
      nextpage: data.nextpage,
    );
  }

  Future<StreamList<SearchData>?> searchNextPage({
    required String nextpage,
    required String query,
    required SearchFilter filter,
  }) async {
    final searchPage = (await api.searchNextPage(
      nextpage: nextpage,
      q: query,
      filter: filter,
    ))
        .data;

    if (searchPage?.items == null) return null;

    final results = searchPage!.items!
        .map(
          (e) => SearchData(data: e.data),
        )
        .toBuiltList();

    return StreamList(
      streams: results,
      nextpage: searchPage.nextpage,
    );
  }
}
