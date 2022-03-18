import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sftube/providers/providers.dart';

void resetDefaults(WidgetRef ref) {
  ref.watch(downloadPathProvider).reset();
  ref.watch(themeTypeProvider.notifier).reset();
  ref.watch(thumbnailDownloaderProvider.notifier).reset();
  ref.watch(regionProvider.notifier).reset();
  ref.watch(rememberChoiceProvider.notifier).reset();
}
