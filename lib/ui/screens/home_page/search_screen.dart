import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/channel_data.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/models/search_data.dart';
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
            itemBuilder: (ctx, index) => index == searchP.results!.length
                ? getCircularProgressIndicator()
                : SearchContentWidget(searchData: searchP.results![index]),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

class SearchContentWidget extends StatelessWidget {
  const SearchContentWidget({
    super.key,
    required this.searchData,
  });

  final SearchData searchData;

  @override
  Widget build(BuildContext context) {
    switch (searchData.type) {
      case SearchType.channel:
        final channel = searchData.data as ChannelData;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: ChannelDetails(
            channelId: channel.id.value,
          ),
        );
      case SearchType.video:
        final video = searchData.data as VideoData;
        return PSVideo(
          videoData: video,
          isRow: !context.isMobile,
          loadData: true,
        );

      case SearchType.playlist:
        final playlist = searchData as PlaylistData;
        return PSPlaylist(
          playlist: playlist,
        );
    }
  }
}
