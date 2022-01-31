import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(context) {
    super.build(context);
    final playlist = ref.watch(playlistProvider);
    final playlistP = ref.watch(playlistProvider.notifier);
    final yt = YoutubeExplode();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      children: [
        ListTile(
          leading: const Icon(AntIcons.like),
          title: Text(context.locals.liked),
          onTap: () => context.pushPage(const LikedScreen()),
          trailing: const Icon(Icons.chevron_right),
        ),
        if (playlist.entries.isNotEmpty)
          for (var entry in playlist.entries)
            GestureDetector(
              onTap: () => context.pushPage(
                PlaylistSubScreen(
                  playlistName: entry.key,
                  ref: ref,
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
                                  future: yt.videos
                                      .get(entry.value.first)
                                      .whenComplete(() => yt.close()),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? CachedNetworkImage(
                                            imageUrl: snapshot
                                                .data!.thumbnails.mediumResUrl,
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
                      icon: const Icon(AntIcons.minus_outline),
                    ),
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
  final String playlistName;
  final WidgetRef ref;

  const PlaylistSubScreen(
      {Key? key, required this.playlistName, required this.ref})
      : super(key: key);

  @override
  Widget build(context) {
    final playlistP = ref.watch(playlistProvider.notifier);
    final videos = ref
        .watch(playlistProvider)
        .entries
        .where((element) => element.key == playlistName)
        .first
        .value;
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
        leading: context.backLeading(),
      ),
      body: FtBody(
        child: videos.isNotEmpty
            ? ListView(
                children: [
                  for (var videoUrl in videos)
                    FTVideo(
                      isRow: !context.isMobile,
                      videoUrl: videoUrl,
                      actions: [
                        IconButton(
                          onPressed: () {
                            playlistP.removeVideo(playlistName, videoUrl);
                          },
                          icon: const Icon(AntIcons.delete_outline),
                        ),
                      ],
                    ),
                ],
              )
            : Center(child: Text(context.locals.noVideosFound)),
      ),
    );
  }
}
