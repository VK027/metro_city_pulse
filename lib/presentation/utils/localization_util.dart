import 'package:metro_city_pulse/core/provider/language_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Riverpod `.tr(ref)` shorthand over the kit's [Translations] cache.
extension StringExtension on String {
  String tr(WidgetRef ref, {Map<String, String>? namedArgs, List<String>? args}) {
    final translations = ref.watch(translationsProvider);
    return translations.tr(this, namedArgs: namedArgs, args: args);
  }
}
