import 'package:flutter/material.dart';
import 'package:inspect/Home/home.dart';
import 'package:inspect/Home/nav_controller.dart';
import 'package:provider/provider.dart';


import '../views/profile_page.dart';
import '../views/help_page.dart';
import '../views/logout_page.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
    const HelpPage(),
    const LogoutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavController(),
      child: Consumer<NavController>(
        builder: (context, controller, _) => Scaffold(
          body: _pages[controller.selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex,
            onTap: controller.changePage,
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
