import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final playlist = ref.watch(playlistProvider);
    final playlistP = ref.watch(playlistProvider.notifier);
    return ListView(
      children: [
        for (var entry in playlist.entries)
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlaylistSubScreen(
                  currentPlaylist: entry,
                  playlistP: playlistP,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey,
                        ),
                        width: 141,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: const Alignment(0.98, 0.94),
                          child: IconWithLabel(
                            label: entry.value.length.toString(),
                            secColor: SecColor.dark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(entry.key),
                ],
              ),
            ),
          )
      ],
    );
  }
}

class PlaylistSubScreen extends StatelessWidget {
  final MapEntry<String, List<String>> currentPlaylist;

  final PlaylistNotifier playlistP;

  const PlaylistSubScreen({Key? key, required this.currentPlaylist, required this.playlistP}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlaylist.key),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: context.back,
        ),
      ),
      body: ListView(
        children: [
          for (var videoUrl in currentPlaylist.value) FTVideo(videoUrl: videoUrl),
        ],
      ),
    );
  }
}
