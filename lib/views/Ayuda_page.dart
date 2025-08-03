import 'package:flutter/material.dart';

class AyudaPage extends StatelessWidget {
  const AyudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Ayuda')),
      body: Center(child: Text('Pantalla de Ayuda')),
    );
  }
}
