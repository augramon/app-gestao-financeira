import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Indica se o onboarding já foi concluído (armazenado localmente).
class OnboardingController extends Notifier<bool> {
  static const _prefsKey = 'onboarding_seen';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> complete() async {
    state = true;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_prefsKey, true);
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);
