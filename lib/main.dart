
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'app.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (Platform.isWindows || Platform.isLinux || Platform.isAndroid) {
//     sqfliteFfiInit();
//     databaseFactory = databaseFactoryFfi;
//   }

//   runApp(const App());
// }


import 'dart:io';
import 'package:barber_demo/core/databases/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';

void main() async {
  // 1. Critical: Bind Framework
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Critical: Initialize FFI for Windows/Linux/macOS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize the FFI loader
    sqfliteFfiInit();
    // Set the global factory
    databaseFactory = databaseFactoryFfi;
    // await DatabaseHelper.instance.resetDatabase();
  }

  // 3. Launch App
  // We do NOT await database creation here. 
  // The app shows a UI, and the UI triggers the DB load safely.
  runApp(
    const ProviderScope(
      child: BarberShopAdminApp(),
    ),
  );
}