import 'package:piped_api/piped_api.dart';
import 'package:pstube/foundation/extensions/stream_format_enum/extension.dart';

class StreamData {
  StreamData({
    required this.quality,
    required this.format,
    required this.url,
  });

  StreamData.fromStream({
    required Stream stream,
  })  : quality = stream.quality!,
        format = stream.format!.getName,
        url = stream.url!;

  final String quality;
  final String format;
  final String url;
}
