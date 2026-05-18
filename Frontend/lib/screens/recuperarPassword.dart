import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class PantallaOlvidePassword extends StatefulWidget {
  const PantallaOlvidePassword({super.key});

  @override
  State<PantallaOlvidePassword> createState() => _PantallaOlvidePasswordState();
}

class _PantallaOlvidePasswordState extends State<PantallaOlvidePassword> {
  // Paso 1: verificar email / Paso 2: nueva contraseña
  int _paso = 1;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nuevaPasswordController = TextEditingController();
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  String? _errorEmail;
  String? _errorNuevaPassword;
  String? _errorConfirmar;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _cargando = false;

  bool _esEmailValido(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }

  Future<void> _verificarEmail() async {
    setState(() => _errorEmail = null);

    if (emailController.text.trim().isEmpty) {
      setState(() => _errorEmail = 'El email es obligatorio');
      return;
    }
    if (!_esEmailValido(emailController.text.trim())) {
      setState(() => _errorEmail = 'Ingresa un email válido');
      return;
    }

    setState(() => _cargando = true);

    try {
      final url = Uri.parse("http://IPlocal:8000/verificar-email");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() => _paso = 2);
      } else {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["detail"] ?? "Email no encontrado"),
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

  Future<void> _cambiarPassword() async {
    setState(() {
      _errorNuevaPassword = null;
      _errorConfirmar = null;
    });

    bool valido = true;

    if (nuevaPasswordController.text.isEmpty) {
      setState(() => _errorNuevaPassword = 'La contraseña es obligatoria');
      valido = false;
    } else if (nuevaPasswordController.text.length < 6) {
      setState(() => _errorNuevaPassword = 'Mínimo 6 caracteres');
      valido = false;
    }

    if (confirmarPasswordController.text.isEmpty) {
      setState(() => _errorConfirmar = 'Confirma tu contraseña');
      valido = false;
    } else if (confirmarPasswordController.text !=
        nuevaPasswordController.text) {
      setState(() => _errorConfirmar = 'Las contraseñas no coinciden');
      valido = false;
    }

    if (!valido) return;

    setState(() => _cargando = true);

    try {
      final url = Uri.parse("http://TU_IP:8000/cambiar-password");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "nueva_password": nuevaPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Contraseña actualizada correctamente!"),
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
            content: Text(data["detail"] ?? "Error al actualizar"),
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
            child: _paso == 1 ? _buildPaso1() : _buildPaso2(),
          ),
        ),
      ),
    );
  }

  Widget _buildPaso1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        const Text(
          'Recuperar Contraseña',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ingresa tu email para continuar',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

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
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _cargando ? null : _verificarEmail,
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
                    'Verificar Email',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿Recordaste tu contraseña?'),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Inicia sesión'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaso2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_open, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        const Text(
          'Nueva Contraseña',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Crea una nueva contraseña para\n${emailController.text.trim()}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Nueva contraseña
        TextField(
          controller: nuevaPasswordController,
          obscureText: _obscureNueva,
          decoration: InputDecoration(
            hintText: 'Nueva contraseña',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: _errorNuevaPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNueva ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscureNueva = !_obscureNueva);
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
                _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscureConfirmar = !_obscureConfirmar);
              },
            ),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _cargando ? null : _cambiarPassword,
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
                    'Guardar Contraseña',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () => setState(() => _paso = 1),
          child: const Text('← Cambiar email'),
        ),
      ],
    );
  }
}
