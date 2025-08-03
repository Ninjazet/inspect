import 'package:flutter/material.dart';

class CerrarSesion extends StatelessWidget {
  const CerrarSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cerrar sesion')),
      body: Center(child: Text('Pantalla de Cerrar sesion')),
    );
  }
}
