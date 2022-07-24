import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/home_page/state/search_notifier.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({
    super.key,
    required this.searchedTerm,
  });

  final ValueNotifier<String> searchedTerm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMounted = useIsMounted();
    final searchP = ref.watch(searchProvider);
    final searchPro = ref.read(searchProvider.notifier);
    final controller = useScrollController();

    Future<void> loadVideos() async {
      if (!isMounted()) return;

      await searchPro.search(searchedTerm.value);
    }

    Future<void> _getMoreData() async {
      if (!isMounted() ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      await searchPro.searchNextPage();
    }

    useEffect(
      () {
        loadVideos();
        controller.addListener(_getMoreData);
        searchedTerm.addListener(loadVideos);

        return () {
          searchedTerm.removeListener(loadVideos);
          controller.removeListener(_getMoreData);
        };
      },
      [controller],
    );

    return searchP.results != null && !searchP.isLoading
        ? ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: context.getBackgroundColor.withOpacity(0.6),
            ),
            shrinkWrap: true,
            controller: controller,
            itemCount: searchP.results!.length + 1,
            itemBuilder: (ctx, idx) => idx == searchP.results!.length
                ? getCircularProgressIndicator()
                : PSVideo(
                    videoData: searchP.results![idx],
                    loadData: true,
                    isRow: !context.isMobile,
                  ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
