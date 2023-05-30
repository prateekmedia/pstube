import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/data/models/playlist_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/states/states.dart';

class PSPlaylist extends ConsumerWidget {
  const PSPlaylist({
    required this.playlist,
    super.key,
  });

  final PlaylistData playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 90,
                    width: 160,
                    decoration: BoxDecoration(
                      color: context.getAlt2BackgroundColor,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: CachedNetworkImage(
                      imageUrl: playlist.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.grey[800]!.withOpacity(0.8),
                    width: 160,
                    padding: const EdgeInsets.all(5),
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.list, size: 18),
                        const SizedBox(width: 6),
                        Text('${playlist.videos} videos'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(playlist.name)),
          AdwButton.circular(
            onPressed: playlist.videos != 0
                ? () => ref.read(playlistProvider).addPlaylist(playlist.name)
                : null,
            size: 36,
            child: Icon(
              LucideIcons.plus,
              size: 20,
              color: playlist.videos == 0 ? Colors.transparent : null,
            ),
          ),
        ],
      ),
    );
  }
}
