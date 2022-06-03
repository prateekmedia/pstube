import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/states/remember_choice/remember_choice.dart';

final rememberChoiceProvider =
    StateNotifierProvider<RememberChoiceNotifier, bool>(
  (_) => RememberChoiceNotifier(
    state: prefs.getBool('remember_choice') ?? false,
  ),
);
