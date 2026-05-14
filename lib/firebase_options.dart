import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase web config is not configured.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase config is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoK4DOABdC7M2JwwUpWzk_OOxzt2ViDJ4',
    appId: '1:787930915859:android:122d7558b4ce3233be0be6',
    messagingSenderId: '787930915859',
    projectId: 'mobile--app-621b4',
    storageBucket: 'mobile--app-621b4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoK4DOABdC7M2JwwUpWzk_OOxzt2ViDJ4',
    appId: '1:787930915859:ios:381d95f142c4351bbe0be6',
    messagingSenderId: '787930915859',
    projectId: 'mobile--app-621b4',
    storageBucket: 'mobile--app-621b4.firebasestorage.app',
    iosBundleId: 'com.zen.japanese',
  );
}
