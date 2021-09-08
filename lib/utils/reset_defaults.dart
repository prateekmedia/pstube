import 'package:flutube/providers/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void resetDefaults(WidgetRef ref) {
  ref.watch(downloadPathProvider).reset();
  ref.watch(themeTypeProvider.notifier).reset();
}
