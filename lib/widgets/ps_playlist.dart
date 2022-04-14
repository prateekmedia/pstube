import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/utils/extensions/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PSPlaylist extends StatelessWidget {
  const PSPlaylist({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final SearchPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 16),
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
                  child: playlist.thumbnails.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: playlist.thumbnails.first.url.toString(),
                          fit: BoxFit.cover,
                        )
                      : null,
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
                      Text('${playlist.playlistVideoCount} videos'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(playlist.playlistTitle),
      ],
    );
  }
}
