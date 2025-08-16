import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inspect/firebase/firebase_service.dart';
import 'package:inspect/service/pdfService.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class InspeccionService {
  final FirebaseService firebaseService;
  final PdfService pdfService;

  InspeccionService({
    required this.firebaseService,
    required this.pdfService,
  });

  Future<File?> guardarInspeccion({
    required BuildContext context,
    required Map<String, String?> respuestas,
    required Map<String, String> datosGenerales,
    required Map<String, String> informacionUnidad,
  }) async {
    File? pdfFile;

    // Mostrar modal de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Obtener número de inspección primero
      final numeroInspeccion = await firebaseService.obtenerNumeroInspeccion();
      final datosConNumero = Map<String, String>.from(datosGenerales);
      datosConNumero.addAll(informacionUnidad);
      datosConNumero['numeroInspeccion'] = numeroInspeccion.toString();

      //  Limpiar 
      final respuestasLimpias =
          respuestas.map((k, v) => MapEntry(k, v ?? ''));

      // Generar PDF
      pdfFile = await pdfService.exportarChecklist(
        respuestasLimpias,
        datosConNumero,
        informacionUnidad
        
      );

      if (pdfFile == null) {
        Navigator.pop(context); 
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            backgroundColor: Colors.white,
            message: 'Error al generar el PDF',
            textStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            icon: const Icon(Icons.error, color: Colors.red),
          ),
        );
        return null;
      }

      // Subir PDF 
      final pdfUrl = await firebaseService.subirPdfYObtenerUrl(
        pdfFile: pdfFile,
        placa: datosConNumero['placa'] ?? '',
        fecha: datosConNumero['fecha'] ?? '',
      );

      // Guardar datos en Firestore
      await firebaseService.guardarInspeccionCompleta(
        conductor: datosConNumero['conductor'] ?? '',
        fecha: datosConNumero['fecha'] ?? '',
        inspector: datosConNumero['inspector'] ?? '',
        placa: informacionUnidad['placa'] ?? '',
        tipoTransporte: informacionUnidad['tipoTransporte' ] ?? '',
        marca: informacionUnidad['marca']  ?? '',
        modelo: informacionUnidad['modelo']  ?? '',
        color: informacionUnidad['color']  ?? '',
        vin: informacionUnidad['vin']  ?? '',
        pdfUrl: pdfUrl,
        numeroInspeccion: numeroInspeccion.toString(),
      );

      
      Navigator.pop(context); 
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          backgroundColor: Colors.white,
          message: 'Inspección registrada con éxito!',
          textStyle: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );

      return pdfFile;
    } catch (e) {
      Navigator.pop(context);
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          backgroundColor: Colors.white,
          message: 'Error al guardar la inspección: $e',
          textStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          icon: const Icon(Icons.error, color: Colors.red),
        ),
      );
      return null;
    }
  }
}
