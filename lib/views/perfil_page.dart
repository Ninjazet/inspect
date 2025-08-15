import 'package:flutter/material.dart';
import 'package:inspect/views/crearUsuarios.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  final String userEmail;
  final String userName;

  static const Color _primary = Color(0xFF004780); // azul base
  static const Color _bg = Color(0xFFF2F6FA); // fondo claro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        centerTitle: true,
        title: const Text('Perfil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con degradado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 28, bottom: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_primary, Color(0xFF00365F)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: _primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bienvenido $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la cuenta',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            color: _primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Nombre: $userName')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.alternate_email,
                            color: _primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Correo:  $userEmail')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ÚNICO botón (estilo moderno) — solo para admin
            if (userEmail == 'admin@fleetcheck.com')
              Center(
                child: PerfilPrimaryButton(
                  text: 'Crear nuevo usuario',
                  icon: Icons.person_add_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Crearusuario(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Botón primario con el estilo de la pantalla (azul degradado + sombra).
class PerfilPrimaryButton extends StatelessWidget {
  const PerfilPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = 240,
    this.height = 50,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double width;
  final double height;

  static const Color _primary = Color(0xFF004780);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      child: Ink(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primary, Color(0xFF00365F)],
          ),
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33004780),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
