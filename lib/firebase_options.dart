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
    apiKey: 'AIzaSyCkfyRhyJVjdMZ1JUICr4NmRRenpZ9itFg',
    appId: '1:39308425920:web:45ccf35fa020236bc30b25',
    messagingSenderId: '39308425920',
    projectId: 'eureka-99ca9',
    authDomain: 'eureka-99ca9.firebaseapp.com',
    storageBucket: 'eureka-99ca9.appspot.com',
    measurementId: 'G-FN6V9MCPG8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOFQsSU1oVz1jEazM7gp15RF81oVahzhw',
    appId: '1:39308425920:android:abb96d639a7a6d6ac30b25',
    messagingSenderId: '39308425920',
    projectId: 'eureka-99ca9',
    storageBucket: 'eureka-99ca9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_R0fVbGfj8ZKnuYCTOJV1ntCQ7__ofHY',
    appId: '1:39308425920:ios:edfa357e887416fcc30b25',
    messagingSenderId: '39308425920',
    projectId: 'eureka-99ca9',
    storageBucket: 'eureka-99ca9.appspot.com',
    iosBundleId: 'com.example.eurekaFinalVersion',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_R0fVbGfj8ZKnuYCTOJV1ntCQ7__ofHY',
    appId: '1:39308425920:ios:edfa357e887416fcc30b25',
    messagingSenderId: '39308425920',
    projectId: 'eureka-99ca9',
    storageBucket: 'eureka-99ca9.appspot.com',
    iosBundleId: 'com.example.eurekaFinalVersion',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCkfyRhyJVjdMZ1JUICr4NmRRenpZ9itFg',
    appId: '1:39308425920:web:4798f7cf70fdc3e2c30b25',
    messagingSenderId: '39308425920',
    projectId: 'eureka-99ca9',
    authDomain: 'eureka-99ca9.firebaseapp.com',
    storageBucket: 'eureka-99ca9.appspot.com',
    measurementId: 'G-XN21KG0BWX',
  );
}