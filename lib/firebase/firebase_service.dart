import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<int> obtenerNumeroInspeccion() async {
  final contadorRef = _db.collection('config').doc('contadorInspecciones');

  return _db.runTransaction((transaction) async {
    final snapshot = await transaction.get(contadorRef);
    int nuevoNumero;

    if (!snapshot.exists) {
      nuevoNumero = 1; // Si no existe, iniciamos en 1
      transaction.set(contadorRef, {'valor': nuevoNumero});
    } else {
      nuevoNumero = snapshot['valor'] + 1;
      transaction.update(contadorRef, {'valor': FieldValue.increment(1)});
    }

    return nuevoNumero;
  });
}

  Future<void> guardarInspeccionBasica({
    required String conductor,
    required String tipoTransporte,
    required String marca,
    required String modelo,
    required String color,
    required String vin,
    required String placa,
    required String fecha,
    required String inspector,
    required String pdfUrl,
  }) async {
    final numero = await obtenerNumeroInspeccion();

    await _db.collection('inspecciones').add({
      'placa': placa,
      'numeroInspeccion': numero.toString(),
      'fecha': fecha,
      'inspector': inspector,
      'conductor': conductor,
      'tipoTransporte': tipoTransporte,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'vin': vin,
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
  required String fecha,
  required String inspector,
  required String conductor,
  required String tipoTransporte,
  required String marca,
  required String modelo,
  required String color,
  required String vin,
  required String pdfUrl,
  required String numeroInspeccion, 
}) async {
  await _db.collection('inspecciones').add({
    'placa': placa,
    'numeroInspeccion': numeroInspeccion,
    'fecha': fecha,
    'inspector': inspector,
    'conductor': conductor,
    'tipoTransporte': tipoTransporte,
    'marca': marca,
    'modelo': modelo,
    'color': color,
    'vin': vin,
    'pdfUrl': pdfUrl,
    'fechaRegistro': FieldValue.serverTimestamp(),
  });
}
}