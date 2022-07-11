import 'package:pstube/foundation/constants.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

class UploaderId {
  UploaderId(String val) : value = parseUploaderId(val) ?? '';

  UploaderId.addPrefix(String val)
      : value = parseUploaderId(Constants.ytCom + val) ?? '';

  final String value;

/*  ChannelId(String value) : value = parseChannelId(value) ?? '' {
    if (this.value.isEmpty) {
      throw ArgumentError.value(value);
    }*/

  /// Returns true if the given id is a valid channel id.
  static bool validateChannelId(String id) {
    if (id.isNullOrWhiteSpace) {
      return false;
    }

    if (!id.startsWith('UC')) {
      return false;
    }

    if (id.length != 24) {
      return false;
    }

    return !RegExp(r'[^0-9a-zA-Z_\-]').hasMatch(id);
  }

  /// Parses a channel id from an url.
  /// Returns null if the username is not found.
  static String? parseUploaderId(String url) {
    if (url.isEmpty) {
      return null;
    }

    if (validateChannelId(url)) {
      return url;
    }

    final regMatch = RegExp(r'youtube\..+?/channel/(.*?)(?:\?|&|/|$)')
        .firstMatch(url)
        ?.group(1);
    if (!regMatch.isNullOrWhiteSpace && validateChannelId(regMatch!)) {
      return regMatch;
    }
    return null;
  }

  @override
  String toString() => value;
}
