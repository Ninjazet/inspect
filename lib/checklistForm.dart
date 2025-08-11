import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspect/preguntas.dart';

class ChecklistForm extends StatefulWidget {
  final void Function(Map<String, String?>) onChanged;
  final void Function(Map<String, String>) onDatosGeneralesChanged;
  final String? numeroInspeccion;

  const ChecklistForm({
    super.key,
    required this.onChanged,
    required this.onDatosGeneralesChanged,
    this.numeroInspeccion,
  });

  @override
  State<ChecklistForm> createState() => _ChecklistFormState();
}

class _ChecklistFormState extends State<ChecklistForm> {
  final Map<String, String?> _respuestas = {};

  final _formKey = GlobalKey<FormState>();
  final _inspectorController = TextEditingController();
  final _fechaController = TextEditingController();
  final _placaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fecha por defecto
    final hoy = DateTime.now();
    final fechaFormateada =
        '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
    _fechaController.text = fechaFormateada;
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
    );
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
                Text(opcion),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeccion(String titulo, List<String> claves) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
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
            tilePadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding:EdgeInsets.only(bottom: 12),
            title: Text(
              titulo,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: claves
                .map(
                  (clave) => Padding(
                    padding: EdgeInsets.symmetric(
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
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: const Text(
            'DATOS GENERALES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: TextFormField(
                readOnly: true,
                initialValue: widget.numeroInspeccion ?? 'Autogenerado',
                decoration: _inputDecoration(
                  label: 'N° de inspección',
                  icon: Icons.format_list_numbered,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: TextFormField(
                controller: _inspectorController,
                decoration: _inputDecoration(
                  label: 'Inspector',
                  icon: Icons.person,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
                onChanged: (_) =>
                    widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: _inputDecoration(
                  label: 'Fecha',
                  icon: Icons.calendar_today,
                ),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) {
                    final formateada =
                        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                    setState(() => _fechaController.text = formateada);
                    widget.onDatosGeneralesChanged(obtenerDatosGenerales());
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: TextFormField(
                controller: _placaController,
                decoration: _inputDecoration(
                  label: 'Número de placa',
                  icon: Icons.directions_car,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
                onChanged: (_) =>
                    widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(7),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Map<String, String> obtenerDatosGenerales() {
    return {
      'inspector': _inspectorController.text,
      'fecha': _fechaController.text,
      'placa': _placaController.text,
    };
  }

  @override
  void dispose() {
    _inspectorController.dispose();
    _fechaController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildDatosGenerales(),
          _buildSeccion('SISTEMA ELÉCTRICO', sistemaElectricoKeys),
          _buildSeccion('PARTE EXTERIOR', parteExteriorKeys),
          _buildSeccion('SISTEMA DE FRENOS', sistemaFrenosKeys),
          _buildSeccion('SISTEMA MECÁNICO', sistemaMecanicoKeys),
          _buildSeccion('SISTEMA DE LLANTAS', sistemaLlantasKeys),
          _buildSeccion('PARTE INTERIOR', parteInteriorKeys),
          _buildSeccion('DOCUMENTOS', documentosKeys),
        ],
      ),
    );
  }
}