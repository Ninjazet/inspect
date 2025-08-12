import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:inspect/preguntas.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {

  final colorEncabezado = PdfColor.fromInt(0xFF003366);

  Future<File?> exportarChecklist(
    Map<String, String> respuestas,
    Map<String, String> datosGenerales,
    Map<String, String> informacionUnidad,

  ) async {
    pw.Widget _lineaDato(String etiqueta, String? valor) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$etiqueta: ',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              valor ?? '',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      );
    }

    pw.TableRow _encabezadoTabla() {
      return pw.TableRow(
        children: [
          pw.Container(
            color: colorEncabezado,
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              'Actividad',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Container(
            color: colorEncabezado,
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              'Si',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Container(
            color: colorEncabezado,
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              'No',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Container(
            color: colorEncabezado,
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              'N/A',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    pw.TableRow _filaDato(String key, String? respuesta) {
      return pw.TableRow(
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(key)),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(respuesta == 'Si' ? 'X' : ''),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(respuesta == 'No' ? 'X' : ''),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(respuesta == 'N/A' ? 'X' : ''),
          ),
        ],
      );
    }

    pw.Widget _seccionTabla(String titulo, List<String> keys) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6), // Espacio pequeño antes de la tabla
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _encabezadoTabla(),
              for (final key in keys) _filaDato(key, respuestas[key]),
            ],
          ),
          pw.SizedBox(height: 12), // Espacio pequeño entre secciones
        ],
      );
    }

    final logoBytes = await rootBundle.load('assets/image/fleetcheck0.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Table(
            border: pw.TableBorder.all(width: 1),
            columnWidths: {
              0: pw.FixedColumnWidth(80),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 80,
                    alignment: pw.Alignment.center,
                    child: pw.Image(logoImage, width: 100, height: 100),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DATOS GENERALES',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        _lineaDato('Inspector', datosGenerales['inspector']),
                        _lineaDato('Conductor', datosGenerales['conductor']),
                        _lineaDato('Fecha', datosGenerales['fecha']),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _lineaDato(
                          'Tipo de Transporte',
                          informacionUnidad['tipoTransporte'],
                        ),
                        _lineaDato('Marca', informacionUnidad['marca']),
                        _lineaDato('Modelo', informacionUnidad['modelo']),
                        _lineaDato('Color', informacionUnidad['color']),
                        _lineaDato('VIN', informacionUnidad['vin']),
                        _lineaDato(
                          'Número de placa',
                          informacionUnidad['placa'],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Reporte de inspección No ${datosGenerales['numeroInspeccion'] ?? ''}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          _seccionTabla('SISTEMA ELÉCTRICO', sistemaElectricoKeys),
          _seccionTabla('PARTE EXTERIOR', parteExteriorKeys),
          _seccionTabla('SISTEMA DE FRENOS', sistemaFrenosKeys),
          _seccionTabla('SISTEMA MECÁNICO', sistemaMecanicoKeys),
          _seccionTabla('SISTEMA DE LLANTAS', sistemaLlantasKeys),
          _seccionTabla('PARTE INTERIOR', parteInteriorKeys),
          _seccionTabla('DOCUMENTOS', documentosKeys),
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
