import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pstube/providers/providers.dart';

String checkIfExists(String path, String name) {
  if (File(path + name).existsSync()) {
    return checkIfExists(
      path,
      '${p.basenameWithoutExtension(name)}(1)${p.extension(name)}',
    );
  } else {
    return name;
  }
}

void resetSettings(WidgetRef ref) {
  ref.watch(downloadPathProvider).reset();
  ref.watch(themeTypeProvider.notifier).reset();
  ref.watch(thumbnailDownloaderProvider.notifier).reset();
  ref.watch(regionProvider.notifier).reset();
  ref.watch(rememberChoiceProvider.notifier).reset();
}
