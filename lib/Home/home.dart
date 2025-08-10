import 'package:flutter/material.dart';
import 'package:inspect/checklist.dart';
import 'package:inspect/views/Recordatorio.dart';
import 'package:inspect/views/historial.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Colores de la identidad visual
  final Color primaryBlue = const Color(0xFF004080); // Azul oscuro
  final Color orangeAccent = const Color(0xFFF77F00); // Naranja
  final Color yellowSoft = const Color(0xFFFFD54F); // Amarillo suave
  final Color grayLight = const Color(0xFFF0F4F8); // Gris claro de fondo

  Widget buildCard(
    IconData icon,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white, // fondo blanco para contraste
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryBlue, // texto en azul oscuro
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPressed(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Presionaste "$label"')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 2,
        centerTitle: true,
        title: Text(
          'Inicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 84),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  buildCard(
                    Icons.local_shipping,
                    "Nueva Inspección",
                    orangeAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Checklist(),
                        ),
                      );
                    },
                  ),
                  buildCard(
                    Icons.apartment,
                    "Recordatorios",
                    primaryBlue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordatoriosScreen(),
                        ),
                      );
                    },
                  ),
                  buildCard(
                    Icons.history,
                    "Historial",
                    yellowSoft, // amarillo suave para diferenciar
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistorialInspecciones(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
