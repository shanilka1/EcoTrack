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
    apiKey: 'AIzaSyC9LqTR7e8W-oev92zHnTuFQPsdvrd1Py4',
    appId: '1:252310574246:web:fe3ec4f96ccb5c1b551067',
    messagingSenderId: '252310574246',
    projectId: 'ecotrack-100ff',
    authDomain: 'ecotrack-100ff.firebaseapp.com',
    storageBucket: 'ecotrack-100ff.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIrqPtJwfbyWCTSRTCL5JegJ0qEt3zkVg',
    appId: '1:252310574246:android:1acbd676d9530c7c551067',
    messagingSenderId: '252310574246',
    projectId: 'ecotrack-100ff',
    storageBucket: 'ecotrack-100ff.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8dMVixKiZC52fcKsudv-EsDckAQZZ3N8',
    appId: '1:252310574246:ios:eac8d58dea07abb2551067',
    messagingSenderId: '252310574246',
    projectId: 'ecotrack-100ff',
    storageBucket: 'ecotrack-100ff.firebasestorage.app',
    iosBundleId: 'com.ecotrack.ecotrack',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA8dMVixKiZC52fcKsudv-EsDckAQZZ3N8',
    appId: '1:252310574246:ios:eac8d58dea07abb2551067',
    messagingSenderId: '252310574246',
    projectId: 'ecotrack-100ff',
    storageBucket: 'ecotrack-100ff.firebasestorage.app',
    iosBundleId: 'com.ecotrack.ecotrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9LqTR7e8W-oev92zHnTuFQPsdvrd1Py4',
    appId: '1:252310574246:web:636e01bfb0090e27551067',
    messagingSenderId: '252310574246',
    projectId: 'ecotrack-100ff',
    authDomain: 'ecotrack-100ff.firebaseapp.com',
    storageBucket: 'ecotrack-100ff.firebasestorage.app',
  );
}
