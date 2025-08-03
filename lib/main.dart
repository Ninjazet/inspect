
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inspect/Home/main_navigation.dart';
import 'package:inspect/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Inspect ());
}

class Inspect extends StatelessWidget {
  const Inspect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspeccion Flota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home:  MainNavigation(),
    );
  }
}
