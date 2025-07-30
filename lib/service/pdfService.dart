import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

import 'package:path_provider/path_provider.dart';
import '../preguntas.dart';

class PdfService {
  Future<File?> exportarChecklist(
    Map<String, String> respuestas,
    Map<String, String> datosGenerales,
  ) async {
    pw.Widget _lineaDato(String etiqueta, String? valor) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(
          '$etiqueta ${valor ?? ''}',
          style: const pw.TextStyle(fontSize: 12),
        ),
      );
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DATOS GENERALES',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _lineaDato(
                'Nº de inspeccion',
                datosGenerales['numeroInspeccion'],
              ),
              _lineaDato('Inspector', datosGenerales['inspector']),
              _lineaDato('Fecha', datosGenerales['fecha']),
              _lineaDato('Numero de placa', datosGenerales['placa']),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'SISTEMA ELÉCTRICO',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: sistemaElectricoKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'PARTE EXTERIOR',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: parteExteriorKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'SISTEMA DE FRENOS',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: sistemaFrenosKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'SISTEMA MECANICO',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: sistemaMecanicoKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'SISTEMA DE LLANTAS',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: sistemaLlantasKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'PARTE INTERIOR',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: parteInteriorKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'DOCUMENTOS',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Actividad', 'Si', 'No', 'N/A'],
            data: documentosKeys.map((key) {
              final respuesta = respuestas[key];
              return [
                key,
                respuesta == 'Si' ? 'X' : '',
                respuesta == 'No' ? 'X' : '',
                respuesta == 'N/A' ? 'X' : '',
              ];
            }).toList(),
          ),
          
        ],
      ),
    );


    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/checklist_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
