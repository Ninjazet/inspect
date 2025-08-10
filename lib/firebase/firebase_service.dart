import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> guardarInspeccionBasica({
    required String placa,
    required String numeroInspeccion,
    required String fecha,
    required String inspector,
     required String pdfUrl, 
  }) async {
    await _db.collection('inspecciones').add({
      'placa': placa,
      'numeroInspeccion': numeroInspeccion,
      'fecha': fecha,
      'inspector': inspector,
      'pdfUrl': pdfUrl, 
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  Future<String> subirPdfYObtenerUrl({
    required File pdfFile,
    required String placa,
    required String fecha,
  }) async {
    final path = 'pdfs/${placa}_${fecha.replaceAll('/', '-')}.pdf';
    final ref = _storage.ref().child(path);

    final uploadTask = await ref.putFile(pdfFile);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<void> guardarInspeccionCompleta({
    required String placa,
    required String numeroInspeccion,
    required String fecha,
    required String inspector,
    required String pdfUrl,
  }) async {
      final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
  final DateTime fechaInspeccion = inputFormat.parse(fecha);
  final DateTime proximaInspeccion = fechaInspeccion.add(const Duration(days: 30));

    await _db.collection('inspecciones').add({
          'placa': placa,
    'numeroInspeccion': numeroInspeccion,
    'fecha': Timestamp.fromDate(fechaInspeccion),
    'inspector': inspector,
    'pdfUrl': pdfUrl,
    'proximaInspeccion': Timestamp.fromDate(proximaInspeccion),
    'fechaRegistro': FieldValue.serverTimestamp(), });
  }
}
