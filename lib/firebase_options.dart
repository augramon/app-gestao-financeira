// Gerado para o projeto Firebase "spendly-financas-2026".
//
// Para regenerar/atualizar futuramente, use `flutterfire configure`.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opções padrão do Firebase para a plataforma atual.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plataforma não configurada. Rode "flutterfire configure".',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAwZPM5vVUFc3F5AO_AcYzIHy0pgPZyG5A',
    appId: '1:723737670077:web:8f24fc70e2122b582da2d4',
    messagingSenderId: '723737670077',
    projectId: 'spendly-financas-2026',
    authDomain: 'spendly-financas-2026.firebaseapp.com',
    storageBucket: 'spendly-financas-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDNqhjRtSPoVtofxGCHHdkTtReYF_PeTE',
    appId: '1:723737670077:android:48a9fd14395b12462da2d4',
    messagingSenderId: '723737670077',
    projectId: 'spendly-financas-2026',
    storageBucket: 'spendly-financas-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxKvwiCJ1rWQZvx8eoG5EjDi4mYIhSyoM',
    appId: '1:723737670077:ios:9072874df3871a572da2d4',
    messagingSenderId: '723737670077',
    projectId: 'spendly-financas-2026',
    storageBucket: 'spendly-financas-2026.firebasestorage.app',
    iosBundleId: 'com.spendly.spendly',
  );
}
