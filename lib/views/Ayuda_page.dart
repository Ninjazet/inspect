import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'report_issue_page.dart';

class AyudaPage extends StatelessWidget {
  const AyudaPage({super.key});

  static const Color _primary = Color(0xFF004780);
  static const Color _bg = Color(0xFFF2F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        centerTitle: true,
         title:  Text('Ayuda', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¿En qué podemos ayudarte?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Encuentra respuestas rápidas o contáctanos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: [
                _ActionCard(
                  icon: Icons.help_outline,
                  iconColor: Colors.orange,
                  title: 'Preguntas frecuentes',
                  onTap: () => _showFAQ(context),
                ),
                _ActionCard(
                  icon: Icons.chat_bubble_outline,
                  iconColor: Colors.green,
                  title: 'WhatsApp Soporte',
                  onTap: () => _openUrl(
                    Uri.parse(
                      'https://api.whatsapp.com/send?phone=+50493675475&text=Hola.%20Necesito%20ayuda',
                    ),
                  ),
                ),
                _ActionCard(
                  icon: Icons.email_outlined,
                  iconColor: Colors.blue,
                  title: 'Correo de soporte',
                  onTap: () => _openUrl(
                    Uri.parse(
                      'mailto:oemaldonado@uth.hn?subject=Soporte%20Inspect&body=Hola%2C%20necesito%20ayuda...',
                    ),
                  ),
                ),
                _ActionCard(
                  icon: Icons.bug_report_outlined,
                  iconColor: Colors.amber,
                  title: 'Reportar problema',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportIssuePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openUrl(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static void _showFAQ(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqItem(
            q: '¿Cómo inicio sesión?',
            a: 'Usa tu correo y contraseña registrados.',
          ),
          _FaqItem(
            q: '¿Olvidé mi contraseña?',
            a: 'Toca “¿Olvidaste tu contraseña?” en el login.',
          ),
          _FaqItem(
            q: '¿No veo mis inspecciones?',
            a: 'Verifica tu conexión y la cuenta actual.',
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 6,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Text(a, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
