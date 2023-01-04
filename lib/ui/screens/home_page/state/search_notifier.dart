import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/models/search_data.dart';
import 'package:pstube/foundation/services/piped_service.dart';
import 'package:pstube/states/history/provider.dart';

final searchProvider = ChangeNotifierProvider<SearchNotifierProvider>((ref) {
  final api = ref.watch(pipedServiceProvider);
  return SearchNotifierProvider(ref, api);
});

class SearchNotifierProvider extends ChangeNotifier {
  SearchNotifierProvider(this.ref, this.api);

  final Ref ref;
  final PipedService api;

  bool isLoading = true;
  String query = '';
  SearchFilter filter = SearchFilter.videos;
  String? nextPageToken = '';

  StreamList<SearchData>? _searchList;
  BuiltList<SearchData>? get results => _searchList?.streams;

  Future<void> search(String _query) async {
    isLoading = true;
    query = _query;
    _searchList = null;
    notifyListeners();

    ref.read(historyProvider).addSearchedTerm(query);
    final page = await api.search(
      query: query,
      filter: filter,
    );

    if (page?.streams == null) return;

    _searchList = page;
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchNextPage() async {
    if (nextPageToken == null || isLoading) return;
    isLoading = true;
    notifyListeners();

    final nextPage = await api.searchNextPage(
      nextpage: nextPageToken!,
      query: query,
      filter: filter,
    );

    if (nextPage?.streams == null) {
      return;
    }

    nextPageToken = nextPage!.nextpage;

    _searchList = _searchList!.rebuild(nextPage.streams);

    isLoading = false;
    notifyListeners();
  }
}
