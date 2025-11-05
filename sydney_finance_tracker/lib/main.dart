import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sydneys Finance Tracker",
      theme: ThemeData(
        scaffoldBackgroundColor: AppStyles.backgroundColor,
        primarySwatch: Colors.pink,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const ResponsiveLayout(),
    );
  }
}
