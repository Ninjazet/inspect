import 'package:flutter/material.dart';
import 'package:inspect/views/crearUsuarios.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key, required this.userEmail, required this.userName});

  final String userEmail;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pantalla de Perfil',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Muestra el nombre del usuario en lugar del email
            Text(
              '¡Hola, $userName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Correo: $userEmail',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Condición para mostrar el botón
            if (userEmail == 'admin@fleetcheck.com')
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de registro
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Crearusuario()),
                  );
                },
                child: const Text('Crear nuevo usuario'),
              ),
          ],
        ),
      ),
    );
  }
}
