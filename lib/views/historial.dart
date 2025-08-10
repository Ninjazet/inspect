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

  // Colores coherentes con la otra pantalla
  final Color primaryBlue = Color(0xFF004080); // Azul oscuro
  final Color orangeAccent = Color(0xFFF77F00); // Naranja
  final Color yellowSoft = Color(0xFFFFD54F); // Amarillo suave para detalles
  final Color grayLight = Color(0xFFF0F4F8); // Gris claro de fondo

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

  // Método para eliminar inspección
  void _eliminarInspeccion(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro de eliminar?'),
        content: const Text('La acción no se puede deshacer'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('inspecciones')
            .doc(docId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspección eliminada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar inspección: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayLight,
      appBar: AppBar(
        title: Text('Historial de Inspecciones'),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 3,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar por placa, fecha o inspector',
                  prefixIcon: Icon(Icons.search, color: orangeAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: orangeAccent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: primaryBlue),
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
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: TextStyle(color: primaryBlue)));
                  if (!snapshot.hasData)
                    return Center(
                        child: CircularProgressIndicator(color: primaryBlue));

                  final docs = snapshot.data!.docs;

                  final inspeccionesFiltradas = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final placa = (data['placa'] ?? '').toString().toLowerCase();
                    final fecha =
                        _formatearFecha(data['fechaRegistro']).toLowerCase();
                    final inspector =
                        (data['inspector'] ?? '').toString().toLowerCase();

                    return placa.contains(_busqueda) ||
                        fecha.contains(_busqueda) ||
                        inspector.contains(_busqueda);
                  }).toList();

                  if (inspeccionesFiltradas.isEmpty) {
                    return Center(
                        child: Text(
                      'No se encontraron inspecciones.',
                      style: TextStyle(color: primaryBlue, fontSize: 16),
                    ));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: inspeccionesFiltradas.length,
                    itemBuilder: (context, index) {
                      final doc = inspeccionesFiltradas[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 12),
                        shadowColor: orangeAccent.withOpacity(0.3),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          leading: Container(
                            decoration: BoxDecoration(
                              color: orangeAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.assignment,
                              color: orangeAccent,
                              size: 32,
                            ),
                          ),
                          title: Text(
                            'Placa: ${data['placa'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                'Inspector: ${data['inspector'] ?? ''}',
                                style: TextStyle(
                                  color: primaryBlue.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'Fecha: ${_formatearFecha(data['fechaRegistro'])}',
                                style: TextStyle(
                                  color: primaryBlue.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Eliminar inspección',
                                onPressed: () =>
                                    _eliminarInspeccion(context, doc.id),
                              ),
                              Icon(Icons.chevron_right,
                                  color: orangeAccent, size: 28),
                            ],
                          ),
                          onTap: () async {
                            final pdfUrl = data['pdfUrl'] ?? '';
                            if (pdfUrl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('PDF no disponible para esta inspección'),
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
      ),
    );
  }
}
