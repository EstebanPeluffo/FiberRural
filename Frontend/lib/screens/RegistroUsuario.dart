import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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

  bool _esEmailValido(String email) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    String? error, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF4A5568)),
      prefixIcon: Icon(icon, color: const Color(0xFF8B96A5)),
      errorText: error,
      filled: true,
      fillColor: const Color(0xFF161B22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5B9BD5)),
      ),
      suffixIcon: suffix,
    );
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
      final url = Uri.parse("https://fiberrural-api.onrender.com/registro");
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "usuario": usuarioController.text.trim(),
              "password": passwordController.text,
              "email": emailController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));

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
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'FiberRural',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B9BD5),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5B9BD5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF21262D), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1C2A3A),
                border: Border.all(color: const Color(0xFF5B9BD5), width: 2),
              ),
              child: const Icon(
                Icons.person_add,
                size: 40,
                color: Color(0xFF5B9BD5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Crear Cuenta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8EDF3),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Regístrate para reportar fallas',
              style: TextStyle(fontSize: 13, color: Color(0xFF8B96A5)),
            ),
            const SizedBox(height: 28),

            TextField(
              controller: usuarioController,
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: _inputDecoration(
                'Usuario',
                Icons.person_outline,
                _errorUsuario,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: _inputDecoration(
                'Correo electrónico',
                Icons.email_outlined,
                _errorEmail,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: _inputDecoration(
                'Contraseña',
                Icons.lock_outline,
                _errorPassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF8B96A5),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmarPasswordController,
              obscureText: _obscureConfirmar,
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: _inputDecoration(
                'Confirmar contraseña',
                Icons.lock_outline,
                _errorConfirmar,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF8B96A5),
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmar = !_obscureConfirmar),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cargando ? null : _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes cuenta?',
                  style: TextStyle(color: Color(0xFF8B96A5)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(color: Color(0xFF5B9BD5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
