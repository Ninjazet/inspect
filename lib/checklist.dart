import 'package:flutter/material.dart';
import 'package:inspect/checklistForm.dart';
import 'package:inspect/service/pdfService.dart';
import 'package:inspect/firebase/firebase_service.dart';
import 'package:inspect/views/pdfViewer.dart';
import 'package:inspect/service/inspeccionService.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Checklist extends StatefulWidget {
  const Checklist({super.key});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  Map<String, String?> _respuestas = {};
  Map<String, String> _datosGenerales = {};

  final _inspeccionService = InspeccionService(
    firebaseService: FirebaseService(),
    pdfService: PdfService(),
  );

  final Color primaryBlue = const Color(0xFF5677FC);
  final Color backgroundGray = const Color(0xFFF5F7FA);
  final Color orangeAccent = const Color(0xFFFF9800);

  void _onFormChanged(Map<String, String?> data) {
    _respuestas = data;
  }

  void _onDatosGeneralesChanged(Map<String, String> generales) {
    _datosGenerales = generales;
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
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final placa = _datosGenerales['placa'] ?? '';
                      final fecha = _datosGenerales['fecha'] ?? '';
                      final inspector = _datosGenerales['inspector'] ?? '';

                      if ([placa, fecha, inspector].any((e) => e.isEmpty)) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            backgroundColor: orangeAccent,
                            message: 'Completa todos los datos generales',
                            textStyle: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      final pdfFile = await _inspeccionService.guardarInspeccion(
                        context: context,
                        datosGenerales: _datosGenerales,
                        respuestas: _respuestas,
                      );

                      Navigator.of(context).pop(); // Cerrar loading

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
