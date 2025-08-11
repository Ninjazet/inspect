import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inspect/Home/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final storage = GetStorage();
  Color myColor=const Color.fromARGB(255, 0, 71, 128);
  late Size mediaSize;
  bool rememberUser = false;

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // Intenta autenticar con Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());

      // Si llega aquí, el login fue exitoso
      final user = userCredential.user;
      if (user != null) {
        // Guardar datos en GetStorage
        storage.write('logueado', true);
        storage.write('usuario', user.email);

        // Redireccionar
        Get.offAll(MainNavigation(), transition: Transition.rightToLeft);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuario no registrado';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          errorMessage = 'Correo inválido';
          break;
        default:
          errorMessage = 'Error al iniciar sesión: ${e.message}';
      }

      Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error inesperado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  }
 
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: AssetImage("assets/image/flota.jpeg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(top: 80, child: _buildTop()),
            Positioned(bottom: 0, child: _buildBottom()),
          ],
        ),
      ),
    );
  }

Widget _buildTop() {
  return SizedBox(
    width: mediaSize.width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 200.0,
                color: Colors.white,
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
       child: Image.asset(
          'assets/image/fleetcheck0.png', 
          width: 500,
        ),
        )
      ],
    ),
  );
}

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ingresa tus credenciales para continuar",
            style: TextStyle(
              color: myColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            style: TextStyle(color: myColor),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              iconColor: myColor,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Correo no válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            style: TextStyle(color: myColor),
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              iconColor: myColor,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'Mínimo 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                ),
              ),
            elevation: MaterialStateProperty.all(20),
            shadowColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.5)),
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(60)),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white; // Color de fondo cuando se presiona
            }
            return Colors.blue; // Color de fondo por defecto
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.blue; // Color del texto cuando se presiona
          }
          return Colors.white; // Color del texto por defecto
          }),
        ),
        child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
           )
            : const Text(
              'Ingresar',
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Lógica para recuperar contraseña
            },
            child: const Text('¿Olvidaste tu contraseña?',style: TextStyle(color: Color.fromARGB(255, 0, 71, 128))),
            
          ),
        ],
      ),
    );
  }
}
