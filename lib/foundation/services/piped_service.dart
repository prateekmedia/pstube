import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
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

  Future<Response<BuiltList<StreamItem>>> getTrending() => api.trending(
        region: ref.watch(regionProvider),
      );

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
