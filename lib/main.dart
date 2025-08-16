

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inspect/Home/main_navigation.dart';
import 'package:inspect/views/login_screen.dart';

import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  final storage = GetStorage();
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // We save the cache
    storage.write('logueado', true);
    storage.write('userEmail', user.email);
    storage.write('userName', user.displayName);
  } else {
    storage.write('logueado', false);
  }

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