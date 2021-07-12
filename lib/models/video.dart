class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final DateTime date;
  final String owner;
  final int views;

  Video({
    required this.id,
    required this.title,
    required this.owner,
    required this.date,
    required this.views,
    required this.thumbnailUrl,
  });

  factory Video.fromMap(snippet) => Video(
      id: snippet['resourceId']['videoId'],
      title: snippet['title'],
      thumbnailUrl: snippet['thumbnails']['high']['url'],
      owner: snippet['channelTitle'],
      date: DateTime.now().subtract(Duration(days: 30)),
      views: 10000000);
}
