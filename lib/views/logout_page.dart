import 'package:flutter/material.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerrar sesión')),
      body: const Center(child: Text('Pantalla de Cerrar sesión')),
    );
  }
}
