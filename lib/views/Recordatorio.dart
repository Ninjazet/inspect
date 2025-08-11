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

  Future<void> _agregarNota() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) return;

    await _notasCollection.add({
      'texto': texto,
      'fecha': _fechaSeleccionada?.toIso8601String(),
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
      appBar: AppBar(title: Text('Recordatorios simples')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _textoController,
              decoration: InputDecoration(
                labelText: 'Escribe tu nota',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _seleccionarFecha,
                ),
              ),
            ),
          ),
          if (_fechaSeleccionada != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('Fecha: ${_fechaSeleccionada!.toLocal().toString().split(' ')[0]}'),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => setState(() => _fechaSeleccionada = null),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: _agregarNota,
            child: Text('Guardar Nota'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notasCollection.orderBy('fecha', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text('No hay notas'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final fecha = data['fecha'] != null ? DateTime.parse(data['fecha']) : null;

                    return ListTile(
                      title: Text(data['texto']),
                      subtitle: fecha != null ? Text('Para: ${fecha.toLocal().toString().split(' ')[0]}') : null,
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _notasCollection.doc(doc.id).delete(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} class Nota {
  String id;
  String texto;
  DateTime? fecha; // opcional, para futura alerta

  Nota({required this.id, required this.texto, this.fecha});

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'fecha': fecha?.toIso8601String(),
    };
  }

  factory Nota.fromMap(String id, Map<String, dynamic> map) {
    return Nota(
      id: id,
      texto: map['texto'],
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : null,
    );
  }
}