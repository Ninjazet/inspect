import 'package:flutter/material.dart';
import 'package:inspect/checklistForm.dart';
import 'package:inspect/firebase/firebase_service.dart';
import 'package:inspect/service/pdfService.dart';
import 'package:inspect/views/pdfViewer.dart';
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
  final _pdfService = PdfService();
  final _firebaseService = FirebaseService();

  void _onFormChanged(Map<String, String?> data) {
    _respuestas = data;
  }

  void _onDatosGeneralesChanged(Map<String, String> generales) {
    _datosGenerales = generales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inspeccion de unidades')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChecklistForm(
                  onChanged: _onFormChanged,
                  onDatosGeneralesChanged: _onDatosGeneralesChanged,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final placa = _datosGenerales['placa'] ?? '';
                    final numeroInspeccion =
                        _datosGenerales['numeroInspeccion'] ?? '';
                    final fecha = _datosGenerales['fecha'] ?? '';
                    final inspector = _datosGenerales['inspector'] ?? '';

                    if ([
                      placa,
                      numeroInspeccion,
                      fecha,
                      inspector,
                    ].any((e) => e.isEmpty)) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: 'Completa todos los datos generales',
                        ),
                      );

                      return;
                    }

                    final respuestasLimpias = _respuestas.map(
                      (k, v) => MapEntry(k, v ?? ''),
                    );
                    //generar pdf
                    final pdfFile = await _pdfService.exportarChecklist(
                      respuestasLimpias,
                      _datosGenerales,
                    );

                    if (pdfFile == null) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: 'Error al generar el PDF',
                        ),
                      );
                      return;
                    }
                    //subir pdf
                    final pdfUrl = await _firebaseService.subirPdfYObtenerUrl(
                      pdfFile: pdfFile,
                      placa: placa,
                      fecha: fecha,
                    );
                    //guardar
                    await _firebaseService.guardarInspeccionCompleta(
                      placa: placa,
                      numeroInspeccion: numeroInspeccion,
                      fecha: fecha,
                      inspector: inspector,
                      pdfUrl: pdfUrl,
                    );

                    if (!mounted) return;

                    showTopSnackBar(
                      Overlay.of(context),
                       CustomSnackBar.success(
                        message: 'Inspección registrada con exito!',
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(pdfFile: pdfFile),
                      ),
                    );
                  },

                  icon: Icon(Icons.save_alt),
                  label: Text('Guardar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.white, width: 2),
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
