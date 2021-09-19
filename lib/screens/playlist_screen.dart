import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(context) {
    super.build(context);
    final playlist = ref.watch(playlistProvider);
    final playlistP = ref.watch(playlistProvider.notifier);
    final yt = YoutubeExplode();
    return ListView(
      children: [
        for (var entry in playlist.entries)
          GestureDetector(
            onTap: () => context.pushPage(
              PlaylistSubScreen(
                currentPlaylist: entry,
                playlistP: playlistP,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 81,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey,
                        ),
                        width: 144,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: entry.value.isNotEmpty
                            ? FutureBuilder<Video>(
                                future: yt.videos.get(entry.value.first).whenComplete(() => yt.close()),
                                builder: (context, snapshot) {
                                  return snapshot.hasData
                                      ? CachedNetworkImage(
                                          imageUrl: snapshot.data!.thumbnails.mediumResUrl,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : const SizedBox();
                                })
                            : null,
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
                  Expanded(child: Text(entry.key)),
                  IconButton(
                      onPressed: () {
                        playlistP.removePlaylist(entry.key);
                      },
                      icon: const Icon(Icons.delete_forever_outlined)),
                ],
              ),
            ),
          )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
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
        leading: context.backLeading,
      ),
      body: FtBody(
        child: currentPlaylist.value.isNotEmpty
            ? ListView(
                children: [
                  for (var videoUrl in currentPlaylist.value) FTVideo(isRow: !context.isMobile, videoUrl: videoUrl),
                ],
              )
            : const Center(child: Text("No videos found!")),
      ),
    );
  }
}
