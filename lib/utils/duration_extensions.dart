extension DurationExtensions on Duration {
  format() {
    final totalSecs = this.inSeconds;
    final hours = totalSecs ~/ 3600;
    final minutes = (totalSecs % 3600) ~/ 60;
    final seconds = totalSecs % 60;
    final buffer = StringBuffer();

    if (hours > 0) {
      buffer.write('$hours:');
    }
    buffer.write('${minutes.toString().padLeft(hours > 0 ? 2 : 1, '0')}:');
    buffer.write(seconds.toString().padLeft(2, '0'));
    return buffer.toString();
  }
}
