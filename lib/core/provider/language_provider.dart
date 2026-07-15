import 'package:metro_city_pulse/core/provider/repository/repository_provider.dart';
import 'package:metro_city_pulse/domain/repositories/local/local_repository.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';


const Locale defaultLocale = Locale("en");

const supportedLocales = [
  Locale('en'), // English
  Locale('es'), // Spanish
];

final translationsProvider = Provider<Translations>((ref) {
  final locale = ref.watch(languageProvider);
  return TranslationCache.translationsFor(locale?.languageCode ?? 'en');
});

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale?>((ref) {
  return LanguageNotifier(ref.read(localRepositoryProvider))..loadLocale();
});

class LanguageNotifier extends StateNotifier<Locale?> {
  final LocalRepository localRepository;

  LanguageNotifier(this.localRepository) : super(null);

  Future<void> loadLocale() async {
    final code = await localRepository.getSavedLocale();
    if (code != null) {
      state = Locale(code);
    } else {
      // Auto-detect from system
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if((systemLocale.languageCode == 'en' || systemLocale.languageCode == 'es')) {
        state = Locale(systemLocale.languageCode);
      } else {
        state = defaultLocale;
      }
    }
  }

  Future<void> changeLocale(String languageCode) async {
    await localRepository.saveLocale(languageCode);
    state = Locale(languageCode);
  }
}
