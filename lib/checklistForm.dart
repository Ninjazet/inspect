import 'package:flutter/material.dart';
import 'preguntas.dart';

class ChecklistForm extends StatefulWidget {
  final void Function(Map<String, String?>) onChanged;
  final void Function(Map<String, String>) onDatosGeneralesChanged;
  const ChecklistForm({
    super.key,
    required this.onChanged,
    required this.onDatosGeneralesChanged,
  });
  @override
  State<ChecklistForm> createState() => _ChecklistFormState();
}

class _ChecklistFormState extends State<ChecklistForm> {
  final Map<String, String?> _respuestas = {};
  


  // Controladores para los datos generales
  final _numeroInspeccionController = TextEditingController();
  final _inspectorController = TextEditingController();
  final _fechaController = TextEditingController();
  final _placaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Establecer fecha actual al campo de fecha
    final hoy = DateTime.now();
    final fechaFormateada =
        '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
    _fechaController.text = fechaFormateada;
  }

  Widget _buildPregunta(String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Si', 'No', 'N/A'].map((opcion) {
            return Row(
              children: [
                Radio<String>(
                  value: opcion,
                  groupValue: _respuestas[key],
                  onChanged: (valor) {
                    setState(() {
                      _respuestas[key] = valor;
                      widget.onChanged(_respuestas);
                    });
                  },
                ),
                Text(opcion, style: const TextStyle(fontSize: 14)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Sección convertida a ExpansionTile para desplegable
  Widget _buildSeccion(String titulo, List<String> claves) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            title: Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: claves
                .map(
                  (clave) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4,
                    ),
                    child: _buildPregunta(clave),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDatosGenerales() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATOS GENERALES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          TextField(
            controller: _numeroInspeccionController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.format_list_numbered),
              labelText: 'N° de inspección',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            onChanged: (_) =>
                widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _inspectorController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Inspector',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            onChanged: (_) =>
                widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _fechaController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
              labelText: 'Fecha',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            onChanged: (_) =>
                widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
          ),

          const SizedBox(height: 16),
          const Text(
            'INFORMACIÓN DE LA UNIDAD',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          TextField(
            controller: _placaController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.directions_car),
              labelText: 'Número de placa',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.blueGrey, width: 3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            onChanged: (_) =>
                widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Map<String, String> obtenerDatosGenerales() {
    return {
      'numeroInspeccion': _numeroInspeccionController.text,
      'inspector': _inspectorController.text,
      'fecha': _fechaController.text,
      'placa': _placaController.text,
    };
  }

  @override
  void dispose() {
    _numeroInspeccionController.dispose();
    _inspectorController.dispose();
    _fechaController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDatosGenerales(),
          _buildSeccion('SISTEMA ELÉCTRICO', sistemaElectricoKeys),
          _buildSeccion('PARTE EXTERIOR', parteExteriorKeys),
          _buildSeccion('SISTEMA DE FRENOS', sistemaFrenosKeys),
          _buildSeccion('SISTEMA MECANICO', sistemaMecanicoKeys),
          _buildSeccion('SISTEMA DE LLANTAS', sistemaLlantasKeys),
          _buildSeccion('PARTE INTERIOR', parteInteriorKeys),
          _buildSeccion('DOCUMENTOS', documentosKeys),
        ],
      ),
    );
  }
}
