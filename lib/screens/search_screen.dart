import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/widgets/ft_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../utils/utils.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 18);
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, size: 22),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left, size: 22),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResult(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SuggestionList(
      query: query,
      onTap: (value) {
        query = value;
        showResults(context);
      },
    );
  }
}

class SearchResult extends HookWidget {
  const SearchResult({
    Key? key,
    required this.query,
  }) : super(key: key);

  final String query;

  @override
  Widget build(BuildContext context) {
    var yt = YoutubeExplode();
    Future<SearchList> loadVideos() async =>
        await yt.search.getVideos(query).whenComplete(() => yt.close());

    return FutureBuilder<SearchList>(
        future: loadVideos(),
        builder: (context, snapshot) {
          final videosList = snapshot.data;
          return snapshot.hasData && videosList != null
              ? ListView.builder(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  itemCount: videosList.length,
                  itemBuilder: (ctx, idx) => FTVideo(
                    videoData: videosList[idx],
                    isRow: context.width >= mobileWidth,
                  ),
                )
              : const CircularProgressIndicator().center();
        });
  }
}

class SuggestionList extends HookWidget {
  final Function(String value) onTap;
  final String query;

  const SuggestionList({
    Key? key,
    required this.query,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yt = YoutubeExplode();
    Future<List<String>> getSuggestions() =>
        yt.search.getQuerySuggestions(query).whenComplete(() => yt.close());
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder<List<String>>(
          future: getSuggestions(),
          builder: (ctx, snapshot) => snapshot.data != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, idx) => ListTile(
                    onTap: () => onTap(snapshot.data![idx]),
                    title: Text(snapshot.data![idx]),
                  ),
                )
              : const CircularProgressIndicator().center(),
        ),
      ),
    );
  }
}
