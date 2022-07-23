import 'package:pstube/foundation/constants.dart';

/// The id of the video.
class VideoId {
  VideoId(
    String idOrUrl,
  ) : value =
            idOrUrl.startsWith('/watch') || idOrUrl.startsWith(Constants.ytCom)
                ? idOrUrl.split('?v=').last
                : idOrUrl;

  /// Initializes an instance of [VideoId] with a url or video id.
  final String value;

  String get url => '${Constants.ytCom}/watch?v=$value';
}
