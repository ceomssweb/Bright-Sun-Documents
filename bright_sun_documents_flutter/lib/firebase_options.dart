import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhl6vjZyG5bDB5MQJ8BSnWi5oUu8gxAXE',
    appId: '1:555788329592:web:cb18b4f046d6f19947838d',
    messagingSenderId: '555788329592',
    projectId: 'bright-sun-documents',
    authDomain: 'bright-sun-documents.firebaseapp.com',
    databaseURL:
        'https://bright-sun-documents-default-rtdb.firebaseio.com',
    storageBucket: 'bright-sun-documents.appspot.com',
    measurementId: 'G-MDETWJJ8T0',
  );

  // For Android and iOS, you will need to run `flutterfire configure`
  // to generate the platform-specific config files (google-services.json / GoogleService-Info.plist).
  // These placeholder options use the same web config; replace after running flutterfire configure.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhl6vjZyG5bDB5MQJ8BSnWi5oUu8gxAXE',
    appId: '1:555788329592:web:cb18b4f046d6f19947838d',
    messagingSenderId: '555788329592',
    projectId: 'bright-sun-documents',
    databaseURL:
        'https://bright-sun-documents-default-rtdb.firebaseio.com',
    storageBucket: 'bright-sun-documents.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhl6vjZyG5bDB5MQJ8BSnWi5oUu8gxAXE',
    appId: '1:555788329592:web:cb18b4f046d6f19947838d',
    messagingSenderId: '555788329592',
    projectId: 'bright-sun-documents',
    databaseURL:
        'https://bright-sun-documents-default-rtdb.firebaseio.com',
    storageBucket: 'bright-sun-documents.appspot.com',
    iosBundleId: 'com.brightsundocuments.brightSunDocumentsFlutter',
  );
}
