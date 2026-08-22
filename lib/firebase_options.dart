import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] configuration for EcoTrack.
///
/// NOTE: In a production deployment, run `flutterfire configure` to generate
/// your project's unique platform configuration credentials.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyEcoTrackWebPlaceholderKey12345',
    appId: '1:100000000000:web:ecotrack0000000000000',
    messagingSenderId: '100000000000',
    projectId: 'ecotrack-app',
    authDomain: 'ecotrack-app.firebaseapp.com',
    storageBucket: 'ecotrack-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyEcoTrackAndroidPlaceholderKey123',
    appId: '1:100000000000:android:ecotrack0000000000',
    messagingSenderId: '100000000000',
    projectId: 'ecotrack-app',
    storageBucket: 'ecotrack-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyEcoTrackIOSPlaceholderKey1234567',
    appId: '1:100000000000:ios:ecotrack00000000000000',
    messagingSenderId: '100000000000',
    projectId: 'ecotrack-app',
    storageBucket: 'ecotrack-app.appspot.com',
    iosBundleId: 'com.ecotrack.ecotrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyEcoTrackMacOSPlaceholderKey12345',
    appId: '1:100000000000:ios:ecotrack00000000000000',
    messagingSenderId: '100000000000',
    projectId: 'ecotrack-app',
    storageBucket: 'ecotrack-app.appspot.com',
    iosBundleId: 'com.ecotrack.ecotrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyEcoTrackWindowsPlaceholderKey123',
    appId: '1:100000000000:web:ecotrack0000000000000',
    messagingSenderId: '100000000000',
    projectId: 'ecotrack-app',
    authDomain: 'ecotrack-app.firebaseapp.com',
    storageBucket: 'ecotrack-app.appspot.com',
  );
}
