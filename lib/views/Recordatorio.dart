import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotasPage extends StatefulWidget {
  @override
  _NotasPageState createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _textoController = TextEditingController();
  DateTime? _fechaSeleccionada;

  final _notasCollection = FirebaseFirestore.instance.collection('notas');

  final Color primaryBlue = const Color(0xFF004080);
  final Color orangeAccent = const Color(0xFFF77F00);
  final Color yellowSoft = const Color(0xFFFFD54F);
  final Color grayLight = const Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _checkNotasPendientes();
  }

  Future<void> _checkNotasPendientes() async {
    final hoy = DateTime.now();
    final hoySoloDia = DateTime(hoy.year, hoy.month, hoy.day);

    final snapshot = await _notasCollection.where('fecha', isNotEqualTo: null).get();

    final notasPendientes = snapshot.docs.where((doc) {
      final data = doc.data();
      if (data['fecha'] == null) return false;
      final fechaNota = DateTime.parse(data['fecha']);
      final fechaSoloDia = DateTime(fechaNota.year, fechaNota.month, fechaNota.day);
      return fechaSoloDia == hoySoloDia;
    }).toList();

    if (notasPendientes.isNotEmpty) {
      final mensajes = notasPendientes.map((doc) => doc['texto']).join('\n• ');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: grayLight,
          title: Text('Recordatorios para hoy', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: Text('• $mensajes', style: TextStyle(color: primaryBlue)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar', style: TextStyle(color: orangeAccent)),
            ),
          ],
        ),
      );
    }
  }

Future<void> _agregarNota() async {
  final texto = _textoController.text.trim();
  if (texto.isEmpty) return;

  if (_fechaSeleccionada == null) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: grayLight,
        title: Text(
          'Fecha requerida',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
      
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: orangeAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return;
  }

  await _notasCollection.add({
    'texto': texto,
    'fecha': _fechaSeleccionada!.toIso8601String(),
  });

  _textoController.clear();
  setState(() => _fechaSeleccionada = null);
}


  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? ahora,
      firstDate: ahora.subtract(Duration(days: 365)),
      lastDate: ahora.add(Duration(days: 365 * 5)),
      builder: (context, child) {
        // Aplica tema personalizado para el datepicker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: primaryBlue, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: orangeAccent),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 2,
        centerTitle: true,
        title: Text(
          'Recordatorios Simples',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textoController,
              decoration: InputDecoration(
                labelText: 'Escribe tu nota',
                labelStyle: TextStyle(color: primaryBlue),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: primaryBlue),
                  onPressed: _seleccionarFecha,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: orangeAccent, width: 2),
                ),
              ),
              cursorColor: primaryBlue,
              style: TextStyle(color: primaryBlue),
            ),
            if (_fechaSeleccionada != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 8),
                child: Row(
                  children: [
                    Icon(Icons.event_note, color: orangeAccent),
                    SizedBox(width: 8),
                    Text(
                      'Fecha: ${_fechaSeleccionada!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: orangeAccent),
                      onPressed: () => setState(() => _fechaSeleccionada = null),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agregarNota,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 6,
                ),
                child: Text(
                  'Guardar Nota',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notasCollection.orderBy('fecha', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator(color: primaryBlue));

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty)
                    return Center(
                      child: Text(
                        'No hay notas',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
                      ),
                    );

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final fecha = data['fecha'] != null ? DateTime.parse(data['fecha']) : null;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        shadowColor: orangeAccent.withOpacity(0.3),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          title: Text(
                            data['texto'],
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: fecha != null
                              ? Text(
                                  'Para: ${fecha.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(color: orangeAccent),
                                )
                              : null,
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: orangeAccent),
                            onPressed: () => _notasCollection.doc(doc.id).delete(),
                          ),
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
