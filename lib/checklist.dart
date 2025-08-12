import 'package:flutter/material.dart';
import 'package:inspect/checklistForm.dart';
import 'package:inspect/service/pdfService.dart';
import 'package:inspect/firebase/firebase_service.dart';
import 'package:inspect/views/pdfViewer.dart';
import 'package:inspect/service/inspeccionService.dart';

class Checklist extends StatefulWidget {
  const Checklist({super.key});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  Map<String, String?> _respuestas = {};
  Map<String, String> _datosGenerales = {};
  Map<String, String> _informacionUnidad = {};

  final _inspeccionService = InspeccionService(
    firebaseService: FirebaseService(),
    pdfService: PdfService(),
  );

  final Color primaryBlue = const Color(0xFF5677FC);
  final Color backgroundGray = const Color(0xFFF5F7FA);

  void _onFormChanged(Map<String, String?> data) {
    _respuestas = data;
  }

  void _onDatosGeneralesChanged(Map<String, String> generales) {
    _datosGenerales = generales;
  }

  void _ondInformacionUnidadChanged(Map<String, String> informacion){
    _informacionUnidad = informacion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('Inspección de unidades'),
        backgroundColor: primaryBlue,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ChecklistForm(
                  onChanged: _onFormChanged,
                  onDatosGeneralesChanged: _onDatosGeneralesChanged,
                  onInformacionUnidad: _ondInformacionUnidadChanged,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      final inspeccionService = InspeccionService(
                        firebaseService: FirebaseService(),
                        pdfService: PdfService(),
                      );
                      final pdfFile = await _inspeccionService
                          .guardarInspeccion(
                            context: context,
                            datosGenerales: _datosGenerales,
                            informacionUnidad: _informacionUnidad,
                            respuestas: _respuestas,
                          );

                      Navigator.of(context).pop(); // cerrar loading

                      if (pdfFile != null && mounted) {
                        setState(() {
                          _respuestas.clear();
                          _datosGenerales.clear();
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(pdfFile: pdfFile),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_alt, color: Colors.white),
                    label: const Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
