import 'package:flutter/material.dart';
import 'package:inspect/checklist.dart';
import 'package:inspect/historial.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

body: Center(

child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('checklit'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Checklist()),
                );
              },
            ),
             ElevatedButton(
              child: const Text('Historial'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistorialInspeccionesScreen()),
                );
              },
            ),
            
            ]
),



),





    );
  }
}