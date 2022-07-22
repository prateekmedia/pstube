import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
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

  BuiltList<SearchItem>? searchList;

  Future<void> search(String _query) async {
    isLoading = true;
    query = _query;
    searchList = null;
    notifyListeners();

    ref.read(historyProvider).addSearchedTerm(query);
    final page = await api.search(
      query: query,
      filter: filter,
    );

    if (page?.items == null) return;

    searchList = page!.items;
    nextPageToken = page.nextpage;
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

    if (nextPage == null || nextPage.items != null) {
      return;
    }

    nextPageToken = nextPage.nextpage;

    searchList = searchList!.rebuild(
      (b) => b.addAll(
        nextPage.items!.toList(),
      ),
    );
    isLoading = false;
    notifyListeners();
  }
}
