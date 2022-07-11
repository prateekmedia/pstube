import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/remember_choice/remember_choice.dart';

final rememberChoiceProvider =
    StateNotifierProvider<RememberChoiceNotifier, bool>(
  (_) => RememberChoiceNotifier(
    state: prefs.getBool('remember_choice') ?? false,
  ),
);
