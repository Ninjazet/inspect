import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inspect/Home/home.dart';
import 'package:inspect/Home/nav_controller.dart';
import 'package:inspect/views/login_screen.dart';
import 'package:provider/provider.dart';

import '../views/perfil_page.dart';
import '../views/Ayuda_page.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static final List<Widget> _pages = [
    const HomePage(),
    const PerfilPage(),
    const AyudaPage(),
  ];

  void _logout(BuildContext context) async {
    // Muestra el cuadro de diálogo de confirmación
    final box = GetStorage();
    //limpiar datos
    void _clearLocalData() {
      box.erase();
    }

    Future<void> _signOutFirebase() async {
      await FirebaseAuth.instance.signOut();
    }

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 71, 128),
            ), // Título en azul
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 71, 128),
            ), // Contenido en azul
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.blue), // Botón 'No' en azul
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sí',
                style: TextStyle(color: Colors.blue), // Botón 'Sí' en azul
              ),
            ),
          ],
        );
      },
    );

    // Si el usuario confirmó, procede con el cierre de sesión
    if (shouldLogout == true) {
      await _signOutFirebase();
      _clearLocalData();

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const _LogoutSplash(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavController(),
      child: Consumer<NavController>(
        builder: (context, controller, _) => Scaffold(
          body: _pages[controller.selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex,
            onTap: (index) {
              if (index == 3) {
                _logout(context);
              } else {
                controller.changePage(index);
              }
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black54,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                label: 'Ayuda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: 'Cerrar sesión',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget del splash (pantalla de carga)
class _LogoutSplash extends StatefulWidget {
  const _LogoutSplash();

  @override
  State<_LogoutSplash> createState() => _LogoutSplashState();
}

class _LogoutSplashState extends State<_LogoutSplash> {
  @override
  void initState() {
    super.initState();

    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // Simula el tiempo de cierre de sesión
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navega a la pantalla de login una vez que el splash ha terminado
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Cerrando sesión...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
