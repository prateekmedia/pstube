import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/ui/states/states.dart';

class PlaylistPopup extends ConsumerWidget {
  const PlaylistPopup({
    super.key,
    required this.videoData,
  });

  final VideoData videoData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider).playlist;
    final playlistP = ref.read(playlistProvider.notifier);
    return Column(
      children: [
        for (var entry in playlist.entries)
          CheckboxListTile(
            value: entry.value.contains(videoData.id.url),
            onChanged: (isTrue) {
              if (isTrue!) {
                playlistP.addVideo(entry.key, videoData.id.url);
                return;
              }

              playlistP.removeVideo(entry.key, videoData.id.url);
            },
            title: Text(entry.key),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
