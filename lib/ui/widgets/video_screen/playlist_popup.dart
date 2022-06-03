import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/ui/states/states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistPopup extends ConsumerWidget {
  const PlaylistPopup({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  final Video videoData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider).playlist;
    final playlistP = ref.read(playlistProvider.notifier);
    return Column(
      children: [
        for (var entry in playlist.entries)
          CheckboxListTile(
            value: entry.value.contains(videoData.url),
            onChanged: (value) {
              if (value!) {
                playlistP.addVideo(entry.key, videoData.url);
              } else {
                playlistP.removeVideo(entry.key, videoData.url);
              }
            },
            title: Text(entry.key),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
