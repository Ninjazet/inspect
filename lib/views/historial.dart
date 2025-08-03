import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

class HistorialInspecciones extends StatefulWidget {
  const HistorialInspecciones({super.key});

  @override
  State<HistorialInspecciones> createState() => _HistorialInspeccionesState();
}

class _HistorialInspeccionesState extends State<HistorialInspecciones> {
  String _busqueda = '';

  String _formatearFecha(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} - '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<Uint8List> _descargarPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al descargar el PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Inspecciones')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por placa, fecha o inspector',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inspecciones')
                  .orderBy('fechaRegistro', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                final inspeccionesFiltradas = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final placa = (data['placa'] ?? '').toString().toLowerCase();
                  final fecha = _formatearFecha(
                    data['fechaRegistro'],
                  ).toLowerCase();
                  final inspector = (data['inspector'] ?? '')
                      .toString()
                      .toLowerCase();

                  return placa.contains(_busqueda) ||
                      fecha.contains(_busqueda) ||
                      inspector.contains(_busqueda);
                }).toList();

                if (inspeccionesFiltradas.isEmpty) {
                  return Center(child: Text('No se encontraron inspecciones.'));
                }

                return ListView.builder(
                  itemCount: inspeccionesFiltradas.length,
                  itemBuilder: (context, index) {
                    final doc = inspeccionesFiltradas[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.assignment),
                        title: Text('Placa: ${data['placa'] ?? ''}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Inspector: ${data['inspector'] ?? ''}'),
                            Text(
                              'Fecha: ${_formatearFecha(data['fechaRegistro'])}',
                            ),
                          ],
                        ),
                        onTap: () async {
                          final pdfUrl = data['pdfUrl'] ?? '';
                          if (pdfUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'PDF no disponible para esta inspección',
                                ),
                              ),
                            );
                            return;
                          }
                          try {
                            final pdfBytes = await _descargarPdf(pdfUrl);
                            await Printing.layoutPdf(
                              onLayout: (format) async => pdfBytes,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al cargar el PDF: $e'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
