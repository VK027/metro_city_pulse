// To initialize all the async dependencies, like SharedPreference, Firebase
import 'package:metro_city_pulse/core/dependency_manager.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

Future<void> configureDependencies() async {
  await DependencyManager.get().init();
  // await Firebase.initializeApp(); // <- Init Firebase
  await Future.wait([
  // Preload all locales before app starts (files: assets/translations/app_<locale>.arb)
   TranslationCache.preload(['en', 'es'], assetPrefix: 'app_'),
  ]).then((value) {
    
  },).onError((error, stackTrace) {
    
  },).catchError((error){

  }, test: (error) => true);
}