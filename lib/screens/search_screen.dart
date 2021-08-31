import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/widgets/ft_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import '../utils/utils.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchTextController = FloatingSearchBarController();
    final yt = YoutubeExplode();
    final videosList = useState([]);
    final searchModel = useState<String>('');

    Future<List<String>> getSuggestions() => yt.search
        .getQuerySuggestions(searchModel.value)
        .whenComplete(() => yt.close());

    void loadVideos() async {
      videosList.value = [];
      var yt = YoutubeExplode();
      videosList.value = await yt.search
          .getVideos(searchModel.value)
          .whenComplete(() => yt.close());
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FloatingSearchBar(
        onQueryChanged: (query) => searchModel.value = query,
        clearQueryOnClose: false,
        onSubmitted: (query) {
          searchTextController.close();
          loadVideos();
        },
        controller: searchTextController,
        transitionCurve: Curves.easeInOutCubic,
        transition: CircularFloatingSearchBarTransition(),
        physics: const BouncingScrollPhysics(),
        scrollPadding: const EdgeInsets.all(4),
        builder: (context, _) => Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FutureBuilder<List<String>>(
              future: getSuggestions(),
              builder: (ctx, snapshot) => snapshot.data != null
                  ? Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, idx) => ListTile(
                                onTap: () {
                                  searchTextController.close();
                                  searchTextController.query =
                                      snapshot.data![idx];
                                  loadVideos();
                                },
                                title: Text(snapshot.data![idx]),
                              )),
                    )
                  : const CircularProgressIndicator().center(),
            ),
          ),
        ),
        body: videosList.value.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 48),
                controller: ScrollController(),
                itemCount: videosList.value.length,
                itemBuilder: (ctx, idx) => FTVideo(
                  videoData: videosList.value[idx],
                  isRow: context.width >= mobileWidth,
                ),
              )
            : searchModel.value.isEmpty
                ? const Center(
                    child: Text("Tap the search bar to begin your search."),
                  )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
