import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inspect/Home/main_navigation.dart';
import 'package:inspect/views/login_screen.dart';

import 'firebase/firebase_options.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    final hayData = storage.read("logueado") ?? false;
    final userEmail = storage.read("userEmail") ?? '';
    final userName = storage.read("userName") ?? '';

    return GetMaterialApp(
      title: 'Inspección Flota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: hayData ? MainNavigation(
        userEmail: userEmail,
        userName: userName,
      ) : LoginScreen(),
    );
  }
}
