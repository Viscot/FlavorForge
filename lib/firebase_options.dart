// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB5aJLisX5oDlqAAO9__yir496mIhB7EFw',
    appId: '1:943630585933:web:fc6fae227a3c6feb1f4c04',
    messagingSenderId: '943630585933',
    projectId: 'flavorforge-ac857',
    authDomain: 'flavorforge-ac857.firebaseapp.com',
    storageBucket: 'flavorforge-ac857.appspot.com',
    measurementId: 'G-2E96VLRQW5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAn7Dw5Mxr_wbX9x12VJK5CtEnMT6036Ns',
    appId: '1:943630585933:android:2245ed63539818251f4c04',
    messagingSenderId: '943630585933',
    projectId: 'flavorforge-ac857',
    storageBucket: 'flavorforge-ac857.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMF_X7QrfyfnVJR9Bjdm_hAHFVBansokY',
    appId: '1:943630585933:ios:3be24da3c0be8e6b1f4c04',
    messagingSenderId: '943630585933',
    projectId: 'flavorforge-ac857',
    storageBucket: 'flavorforge-ac857.appspot.com',
    iosBundleId: 'com.example.flavorforge',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMF_X7QrfyfnVJR9Bjdm_hAHFVBansokY',
    appId: '1:943630585933:ios:3be24da3c0be8e6b1f4c04',
    messagingSenderId: '943630585933',
    projectId: 'flavorforge-ac857',
    storageBucket: 'flavorforge-ac857.appspot.com',
    iosBundleId: 'com.example.flavorforge',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB5aJLisX5oDlqAAO9__yir496mIhB7EFw',
    appId: '1:943630585933:web:d3f13d06ddd32bf61f4c04',
    messagingSenderId: '943630585933',
    projectId: 'flavorforge-ac857',
    authDomain: 'flavorforge-ac857.firebaseapp.com',
    storageBucket: 'flavorforge-ac857.appspot.com',
    measurementId: 'G-4MXHK6LY2G',
  );
}
