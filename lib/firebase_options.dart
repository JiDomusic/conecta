import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Solo soportado en web por ahora');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCeyE8DwqRMdnhzguIbj9WAVE1PawYwhAY",
    authDomain: "conecta-274ca.firebaseapp.com",
    projectId: "conecta-274ca",
    storageBucket: "conecta-274ca.appspot.com",
    messagingSenderId: "745291508141",
    appId: "1:745291508141:web:ef6138867aa9e0c54ed924",
  );
}
