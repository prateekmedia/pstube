import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:pstube/providers/providers.dart';
import 'package:pstube/screens/screens.dart';
import 'package:pstube/utils/utils.dart';
import 'package:pstube/widgets/widgets.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playlist = ref.watch(playlistProvider).playlist;
    final playlistP = ref.watch(playlistProvider.notifier);
    return AdwClamp.scrollable(
      child: AdwPreferencesGroup(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          AdwActionRow(
            start: const Icon(LucideIcons.thumbsUp),
            title: context.locals.liked,
            onActivated: () => context.pushPage(const LikedScreen()),
            end: const Icon(Icons.chevron_right),
          ),
          if (playlist.entries.isNotEmpty)
            for (var entry in playlist.entries)
              AdwActionRow(
                onActivated: () => context.pushPage(
                  PlaylistSubScreen(
                    playlistName: entry.key,
                    ref: ref,
                  ),
                ),
                title: entry.key,
                end: AdwButton.flat(
                  onPressed: () => playlistP.removePlaylist(entry.key),
                  child: const Icon(LucideIcons.minus),
                ),
              )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PlaylistSubScreen extends StatelessWidget {
  const PlaylistSubScreen({
    Key? key,
    required this.playlistName,
    required this.ref,
  }) : super(key: key);

  final String playlistName;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final playlistP = ref.watch(playlistProvider.notifier);
    final videos = ref
        .watch(playlistProvider)
        .playlist
        .entries
        .where((element) => element.key == playlistName)
        .first
        .value;
    return AdwScaffold(
      actions: AdwActions().bitsdojo,
      start: [context.backLeading()],
      title: Text(playlistName),
      body: SFBody(
        child: videos.isNotEmpty
            ? ListView(
                children: [
                  for (var videoUrl in videos)
                    SFVideo(
                      isRow: !context.isMobile,
                      videoUrl: videoUrl,
                      actions: [
                        AdwButton.circular(
                          onPressed: () =>
                              playlistP.removeVideo(playlistName, videoUrl),
                          child: const Icon(LucideIcons.trash),
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
