import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Container(
                height: 90,
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(5),
                child: CachedNetworkImage(
                  imageUrl: playlist.thumbnails.first.url.toString(),
                  fit: BoxFit.cover,
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
