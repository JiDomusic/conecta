// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
          'DefaultFirebaseOptions no soporta esta plataforma',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCeyE8DwqRMdnhzguIbj9WAVE1PawYwhAY",
    authDomain: "conecta-274ca.firebaseapp.com",
    projectId: "conecta-274ca",
    storageBucket: "conecta-274ca.appspot.com",
    messagingSenderId: "745291508141",
    appId: "1:745291508141:web:ef6138867aa9e0c54ed924",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCeyE8DwqRMdnhzguIbj9WAVE1PawYwhAY",
    appId: "1:745291508141:android:ef6138867aa9e0c54ed924",
    messagingSenderId: "745291508141",
    projectId: "conecta-274ca",
    storageBucket: "conecta-274ca.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCeyE8DwqRMdnhzguIbj9WAVE1PawYwhAY",
    appId: "1:745291508141:ios:ef6138867aa9e0c54ed924",
    messagingSenderId: "745291508141",
    projectId: "conecta-274ca",
    storageBucket: "conecta-274ca.appspot.com",
    iosBundleId: "com.example.conecta", //
  );
}
