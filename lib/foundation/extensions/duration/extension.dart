extension DurationExtensions on Duration {
  String format([String defaultVal = 'Shorts']) {
    if (inSeconds == 0) {
      return defaultVal;
    }

    final totalSecs = inSeconds;
    final hours = totalSecs ~/ 3600;
    final minutes = (totalSecs % 3600) ~/ 60;
    final seconds = totalSecs % 60;
    final buffer = StringBuffer();

    if (hours > 0) {
      buffer.write('$hours:');
    }
    buffer
      ..write('${minutes.toString().padLeft(hours > 0 ? 2 : 1, '0')}:')
      ..write(seconds.toString().padLeft(2, '0'));
    return buffer.toString();
  }
}
