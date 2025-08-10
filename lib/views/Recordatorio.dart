import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    Color backgroundColor(int diasRestantes) {
      if (diasRestantes < 0) return Colors.red.shade100;
      if (diasRestantes <= 5) return Colors.orange.shade100;
      return Colors.green.shade100;
    }

    Icon estadoIcon(int diasRestantes) {
      if (diasRestantes < 0) return const Icon(Icons.error, color: Colors.red);
      if (diasRestantes <= 5) return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    String estadoTexto(int diasRestantes) {
      if (diasRestantes < 0) return 'Vencido';
      if (diasRestantes <= 5) return 'Próximo a vencer';
      return 'En día';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recordatorios"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inspecciones')
            .orderBy('proximaInspeccion')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final inspecciones = snapshot.data!.docs;

          if (inspecciones.isEmpty) {
            return const Center(child: Text("No hay recordatorios"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: inspecciones.length,
            itemBuilder: (context, index) {
              final data = inspecciones[index].data() as Map<String, dynamic>;
              final placa = data['placa'] ?? '';

              final Timestamp? fechaUltimaTimestamp = data['fecha'];
              final Timestamp? fechaProximaTimestamp = data['proximaInspeccion'];

              if (fechaUltimaTimestamp == null || fechaProximaTimestamp == null) {
                return const SizedBox();
              }

              final DateTime fechaUltima = fechaUltimaTimestamp.toDate();
              final DateTime fechaProxima = fechaProximaTimestamp.toDate();

              final diasRestantes = fechaProxima.difference(DateTime.now()).inDays;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: backgroundColor(diasRestantes),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      estadoIcon(diasRestantes),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Placa: $placa',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Última inspección: ${formatter.format(fechaUltima)}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              "Próxima inspección: ${formatter.format(fechaProxima)}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            estadoTexto(diasRestantes),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: diasRestantes < 0
                                  ? Colors.red
                                  : (diasRestantes <= 5 ? Colors.orange : Colors.green),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            diasRestantes < 0
                                ? '${-diasRestantes} días vencido'
                                : '$diasRestantes días restantes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
