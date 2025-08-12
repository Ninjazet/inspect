import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final pkg = await PackageInfo.fromPlatform();

    try {
      final android = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'brand': android.brand,
        'model': android.model,
        'sdkInt': android.version.sdkInt,
        'release': android.version.release,
        'appVersion': '${pkg.version}+${pkg.buildNumber}',
        'packageName': pkg.packageName,
      };
    } catch (_) {
      // iOS u otras plataformas
      final ios = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'name': ios.name,
        'model': ios.model,
        'systemName': ios.systemName,
        'systemVersion': ios.systemVersion,
        'appVersion': '${pkg.version}+${pkg.buildNumber}',
        'packageName': pkg.packageName,
      };
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);
    try {
      final meta = await _collectDeviceInfo();

      final doc = await FirebaseFirestore.instance
          .collection('soporte_reportes')
          .add({
            'descripcion': _descCtrl.text.trim(),
            'estado': 'abierto',
            'creadoEn': FieldValue.serverTimestamp(),
            'dispositivo': meta,
          });

      if (!mounted) return;

      final id = doc.id;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reporte enviado'),
          content: Text(
            '¡Gracias! Tu ticket fue creado con el ID:\n\n$id\n\nTe contactaremos pronto.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                // Abrir WhatsApp con el ID del ticket
                final uri = Uri.parse(
                  'https://api.whatsapp.com/send?phone=+50493675475&text=Hola.%20Tengo%20un%20reporte%20(ID:%20$id)',
                );
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: const Text('Enviar por WhatsApp'),
            ),
          ],
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar el reporte: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF004780);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Reportar problema'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cuéntanos qué pasó',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Describe el problema con al menos 10 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_sending ? 'Enviando...' : 'Enviar reporte'),
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2F6FA),
    );
  }
}
