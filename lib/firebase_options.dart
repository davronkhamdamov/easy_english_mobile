// File generated manually / via FlutterFire CLI.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbg0Y1ac4y6HmKuqcruqdiqD2i2D8TUtI',
    appId: '1:807835399839:android:65c00d86c2bda63e3214aa',
    messagingSenderId: '807835399839',
    projectId: 'easy-english-67ec4',
    storageBucket: 'easy-english-67ec4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCy2LwQW5HU6ByxA4YneFCJhEtTaGEktTA',
    appId: '1:807835399839:ios:5a6c90c65d5bde233214aa',
    messagingSenderId: '807835399839',
    projectId: 'easy-english-67ec4',
    storageBucket: 'easy-english-67ec4.firebasestorage.app',
    iosClientId: '807835399839-l2u7dcpqkdlegfvu3ku4tkm60lqqobrg.apps.googleusercontent.com',
    iosBundleId: 'uz.cordialsoft.easyenglish',
  );
}
