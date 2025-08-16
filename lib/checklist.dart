import 'package:flutter/material.dart';
import 'package:inspect/checklistForm.dart';
import 'package:inspect/service/pdfService.dart';
import 'package:inspect/firebase/firebase_service.dart';
import 'package:inspect/views/pdfViewer.dart';
import 'package:inspect/service/inspeccionService.dart';

class Checklist extends StatefulWidget {
  const Checklist({super.key, required this.userName, required this.userEmail});

  final String userName;
  final String userEmail;

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

  
  final GlobalKey<ChecklistFormState> _formKey = GlobalKey<ChecklistFormState>();

  void _onFormChanged(Map<String, String?> data) {
    _respuestas = data;
  }

  void _onDatosGeneralesChanged(Map<String, String> generales) {
    _datosGenerales = generales;
  }

  void _onInformacionUnidadChanged(Map<String, String> informacion) {
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
                  key: _formKey, // clave para acceder al método de validación
                  onChanged: _onFormChanged,
                  onDatosGeneralesChanged: _onDatosGeneralesChanged,
                  onInformacionUnidad: _onInformacionUnidadChanged,
                  userName: widget.userName,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Validar antes de guardar
                      if (!(_formKey.currentState?.validarFormulario() ?? false)) {
                        return; // si falla validación, no sigue
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
                        informacionUnidad: _informacionUnidad,
                        respuestas: _respuestas,
                      );

                      Navigator.of(context).pop(); 

                      if (pdfFile != null && mounted) {
                        setState(() {
                          _respuestas.clear();
                          _datosGenerales.clear();
                          _informacionUnidad.clear();
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(
                              pdfFile: pdfFile,
                              userName: widget.userName,
                              userEmail: widget.userEmail,
                            ),
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
