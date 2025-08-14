import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspect/preguntas.dart';

class ChecklistForm extends StatefulWidget {
  final void Function(Map<String, String?>) onChanged;
  final void Function(Map<String, String>) onDatosGeneralesChanged;
  final void Function(Map<String, String>) onInformacionUnidad;
  final String? numeroInspeccion;
  final String userName;

  const ChecklistForm({
    super.key,
    required this.onChanged,
    required this.onDatosGeneralesChanged,
    required this.onInformacionUnidad,
    required this.userName,
    this.numeroInspeccion,
  });

  @override
  State<ChecklistForm> createState() => ChecklistFormState();
}

class ChecklistFormState extends State<ChecklistForm> {
  final Map<String, String?> _respuestas = {};
  final _formKey = GlobalKey<FormState>();

  // DATOS GENERALES
  final _conductorController = TextEditingController();
  final _fechaController = TextEditingController();

  // INFORMACIÓN DE LA UNIDAD
  final _placaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();

  String _tipoTransporte = 'Cabezal';
  String _marca = 'INTERNATIONAL';

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fechaController.text =
        '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
  }

  String? _campoObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  bool _validarPreguntas(List<String> claves) {
    for (var clave in claves) {
      if (_respuestas[clave] == null) return false;
    }
    return true;
  }

  bool validarFormulario() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    if (!_validarPreguntas(sistemaElectricoKeys) ||
        !_validarPreguntas(parteExteriorKeys) ||
        !_validarPreguntas(sistemaFrenosKeys) ||
        !_validarPreguntas(sistemaMecanicoKeys) ||
        !_validarPreguntas(sistemaLlantasKeys) ||
        !_validarPreguntas(parteInteriorKeys) ||
        !_validarPreguntas(documentosKeys)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Responde todas las preguntas del checklist'),
        ),
      );
      return false;
    }
    return true;
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            title: Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            title: const Text(
              'DATOS GENERALES',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            children: [
              // Inspector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  initialValue: widget.userName,
                  readOnly: true,
                  decoration: _inputDecoration(
                    label: 'Inspector',
                    icon: Icons.person,
                  ),
                ),
              ),
              // Conductor
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _conductorController,
                  decoration: _inputDecoration(
                    label: 'Conductor',
                    icon: Icons.person_3,
                  ),
                  validator: _campoObligatorio,
                  onChanged: (_) =>
                      widget.onDatosGeneralesChanged(obtenerDatosGenerales()),
                ),
              ),
              // Fecha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'INFORMACION DE LA UNIDAD',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Placa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _placaController,
                  decoration: _inputDecoration(
                    label: 'Número de placa',
                    icon: Icons.directions_car,
                  ),
                  validator: _campoObligatorio,
                  onChanged: (_) =>
                      widget.onInformacionUnidad(obtenerInfoUnidad()),
                  inputFormatters: [LengthLimitingTextInputFormatter(7)],
                ),
              ),
              // Tipo de transporte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration(
                    label: 'Tipo de transporte',
                    icon: Icons.airport_shuttle,
                  ),
                  value: _tipoTransporte,
                  items: const [
                    DropdownMenuItem(value: 'Cabezal', child: Text('Cabezal')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _tipoTransporte = value;
                        widget.onInformacionUnidad(obtenerInfoUnidad());
                      });
                    }
                  },
                ),
              ),
              // Marca
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration(
                    label: 'Marca',
                    icon: Icons.format_list_bulleted,
                  ),
                  value: _marca,
                  items: const [
                    DropdownMenuItem(
                      value: 'INTERNATIONAL',
                      child: Text('INTERNATIONAL'),
                    ),
                    DropdownMenuItem(value: 'VOLVO', child: Text('VOLVO')),
                    DropdownMenuItem(value: 'KENWORTH', child: Text('KENWORTH')),
                    DropdownMenuItem(
                      value: 'FREIGHTLINER',
                      child: Text('FREIGHTLINER'),
                    ),
                    DropdownMenuItem(
                      value: 'PETERBILT',
                      child: Text('PETERBILT'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _marca = value;
                        widget.onInformacionUnidad(obtenerInfoUnidad());
                      });
                    }
                  },
                ),
              ),
              // Modelo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _modeloController,
                  decoration: _inputDecoration(
                    label: 'Modelo',
                    icon: Icons.trending_flat,
                  ),
                  validator: _campoObligatorio,
                  onChanged: (_) =>
                      widget.onInformacionUnidad(obtenerInfoUnidad()),
                ),
              ),
              // Color
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _colorController,
                  decoration: _inputDecoration(
                    label: 'Color',
                    icon: Icons.palette,
                  ),
                  validator: _campoObligatorio,
                  onChanged: (_) =>
                      widget.onInformacionUnidad(obtenerInfoUnidad()),
                ),
              ),
              // VIN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _vinController,
                  decoration: _inputDecoration(
                    label: 'VIN',
                    icon: Icons.keyboard,
                  ),
                  validator: _campoObligatorio,
                  onChanged: (_) =>
                      widget.onInformacionUnidad(obtenerInfoUnidad()),
                  inputFormatters: [LengthLimitingTextInputFormatter(17)],
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
      'inspector': widget.userName,
      'conductor': _conductorController.text,
      'fecha': _fechaController.text,
    };
  }

  Map<String, String> obtenerInfoUnidad() {
    return {
      'placa': _placaController.text,
      'modelo': _modeloController.text,
      'color': _colorController.text,
      'vin': _vinController.text,
      'tipoTransporte': _tipoTransporte,
      'marca': _marca,
    };
  }

  @override
  void dispose() {
    _conductorController.dispose();
    _fechaController.dispose();
    _placaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
      ),
    );
  }
}
