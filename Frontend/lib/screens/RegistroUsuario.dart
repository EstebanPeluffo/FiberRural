import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  String? _errorUsuario;
  String? _errorEmail;
  String? _errorPassword;
  String? _errorConfirmar;
  bool _obscurePassword = true;
  bool _obscureConfirmar = true;
  bool _cargando = false;

  bool _esEmailValido(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }

  Future<void> _registrar() async {
    setState(() {
      _errorUsuario = null;
      _errorEmail = null;
      _errorPassword = null;
      _errorConfirmar = null;
    });

    bool valido = true;

    if (usuarioController.text.trim().isEmpty) {
      setState(() => _errorUsuario = 'El usuario es obligatorio');
      valido = false;
    } else if (usuarioController.text.trim().length < 3) {
      setState(() => _errorUsuario = 'Mínimo 3 caracteres');
      valido = false;
    }

    if (emailController.text.trim().isEmpty) {
      setState(() => _errorEmail = 'El email es obligatorio');
      valido = false;
    } else if (!_esEmailValido(emailController.text.trim())) {
      setState(() => _errorEmail = 'Ingresa un email válido');
      valido = false;
    }

    if (passwordController.text.isEmpty) {
      setState(() => _errorPassword = 'La contraseña es obligatoria');
      valido = false;
    } else if (passwordController.text.length < 6) {
      setState(() => _errorPassword = 'Mínimo 6 caracteres');
      valido = false;
    }

    if (confirmarPasswordController.text.isEmpty) {
      setState(() => _errorConfirmar = 'Confirma tu contraseña');
      valido = false;
    } else if (confirmarPasswordController.text != passwordController.text) {
      setState(() => _errorConfirmar = 'Las contraseñas no coinciden');
      valido = false;
    }

    if (!valido) return;

    setState(() => _cargando = true);

    try {
      final url = Uri.parse("http://192.168.1.6:8000/registro");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario": usuarioController.text.trim(),
          "password": passwordController.text,
          "email": emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Cuenta creada exitosamente!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaInicio()),
        );
      } else {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["detail"] ?? "Error al registrar"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de conexión con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FiberRural',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Regístrate para reportar fallas',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 28),

                // Usuario
                TextField(
                  controller: usuarioController,
                  decoration: InputDecoration(
                    hintText: 'Usuario',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: _errorUsuario,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _errorEmail,
                  ),
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _errorPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar contraseña
                TextField(
                  controller: confirmarPasswordController,
                  obscureText: _obscureConfirmar,
                  decoration: InputDecoration(
                    hintText: 'Confirmar contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _errorConfirmar,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmar
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmar = !_obscureConfirmar);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Botón registrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Crear Cuenta',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Volver al login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta?'),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
