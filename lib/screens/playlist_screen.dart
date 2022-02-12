import 'package:ant_icons/ant_icons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';

import 'package:sftube/providers/providers.dart';
import 'package:sftube/screens/screens.dart';
import 'package:sftube/utils/utils.dart';
import 'package:sftube/widgets/widgets.dart';

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
    final playlist = ref.watch(playlistProvider);
    final playlistP = ref.watch(playlistProvider.notifier);
    return AdwClamp.scrollable(
      child: AdwPreferencesGroup(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          AdwActionRow(
            start: const Icon(AntIcons.like),
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
                  onPressed: () {
                    playlistP.removePlaylist(entry.key);
                  },
                  child: const Icon(AntIcons.minus_outline),
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
        .entries
        .where((element) => element.key == playlistName)
        .first
        .value;
    return AdwScaffold(
      headerbar: (_) => AdwHeaderBar.bitsdojo(
        appWindow: getAppwindow(appWindow),
        start: [context.backLeading()],
        title: Text(playlistName),
      ),
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
                          onPressed: () {
                            playlistP.removeVideo(playlistName, videoUrl);
                          },
                          child: const Icon(AntIcons.delete_outline),
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
