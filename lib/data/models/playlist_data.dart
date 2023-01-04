import 'package:piped_api/piped_api.dart';

class PlaylistData {
  PlaylistData({
    required this.name,
    required this.url,
    required this.thumbnail,
    required this.videos,
  });

  PlaylistData.fromPlaylistItem({
    required PlaylistItem searchItem,
  })  : name = searchItem.name!,
        thumbnail = searchItem.thumbnail!,
        url = searchItem.url!,
        videos = searchItem.videos!;

  final String name;
  final String url;
  final String thumbnail;
  final int videos;
}
