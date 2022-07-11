import 'package:piped_api/piped_api.dart';

extension StreamFEnum on StreamFormatEnum {
  String get getName => this == StreamFormatEnum.mPEG4
      ? 'MP4'
      : this == StreamFormatEnum.WEBMA_OPUS
          ? 'OPUS'
          : this == StreamFormatEnum.v3GPP
              ? '3GPP'
              : name.toUpperCase();
}
