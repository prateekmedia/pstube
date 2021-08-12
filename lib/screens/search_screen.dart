import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/widgets/ft_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchTextController = useTextEditingController();
    final sQuery = useState<String>('');
    final isSearching = useState<bool>(true);
    final yt = YoutubeExplode();

    Future<List<String>> getSuggestions() async {
      var suggestions = yt.search.getQuerySuggestions(sQuery.value);
      yt.close();
      return suggestions;
    }

    Future<SearchList> getVideos() async {
      var videos = yt.search.getVideos(sQuery.value);
      yt.close();
      return videos;
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900]!,
          leading: IconButton(
            onPressed: context.back,
            icon: const Icon(Icons.chevron_left),
          ),
          title: Hero(
            tag: 'search',
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: searchTextController,
                autofocus: true,
                onChanged: (query) {
                  EasyDebounce.debounce(
                      'query', const Duration(milliseconds: 100), () {
                    sQuery.value = query;
                  });
                },
                onSubmitted: (query) {
                  isSearching.value = false;
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        BorderSide(color: Colors.grey[800]!, width: 0.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        BorderSide(color: Colors.grey[700]!, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        BorderSide(color: Colors.grey[800]!, width: 0.0),
                  ),
                  filled: true,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const Divider(),
            isSearching.value
                ? FutureBuilder<List<String>>(
                    future: getSuggestions(),
                    builder: (ctx, snapshot) => snapshot.data != null
                        ? Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, idx) => ListTile(
                                      onTap: () {
                                        searchTextController.text =
                                            snapshot.data![idx];
                                        isSearching.value = false;
                                      },
                                      title: Text(snapshot.data![idx]),
                                    )),
                          )
                        : const CircularProgressIndicator().center(),
                  )
                : FutureBuilder<SearchList>(
                    future: getVideos(),
                    builder: (ctx, snapshot) => snapshot.data != null
                        ? Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (ctx, idx) => FTVideo(
                                videoData: snapshot.data![idx],
                                isRow: true,
                              ),
                            ),
                          )
                        : const CircularProgressIndicator().center(),
                  )
          ],
        ),
      ),
    );
  }
}
