import 'package:flutter/material.dart';
import 'package:inspect/checklist.dart';
import 'package:inspect/views/historial.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          color: Colors.grey[100],
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
              style: const TextStyle(fontWeight: FontWeight.w500),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Stack(
            children: [
              /*IconButton(
                icon: const Icon(Icons.notifications, color: Colors.blue),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),*/
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Bienvenido",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    "Nueva Inspeccion",
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Checklist()),
                      );
                    },
                  ),
                  buildCard(
                    Icons.apartment,
                    "ND",
                    Colors.blue,
                    () => showPressed(context, "ND"),
                  ),
                  buildCard(Icons.history, "Historial", Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistorialInspeccionesScreen(),
                      ),
                    );
                  }),
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
