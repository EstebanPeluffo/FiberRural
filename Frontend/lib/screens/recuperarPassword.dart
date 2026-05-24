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
      final url = Uri.parse(
        "https://fiberrural-api.onrender.com/verificar-email",
      );
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
      final url = Uri.parse(
        "https://fiberrural-api.onrender.com/cambiar-password",
      );
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
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
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1C2A3A),
            border: Border.all(color: const Color(0xFF5B9BD5), width: 2),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: Color(0xFF5B9BD5),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8EDF3),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ingresa tu email para continuar',
          style: TextStyle(fontSize: 13, color: Color(0xFF8B96A5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
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
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _cargando ? null : _verificarEmail,
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
                    'Verificar Email',
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
              '¿Recordaste tu contraseña?',
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
    );
  }

  Widget _buildPaso2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
            Icons.lock_open,
            size: 40,
            color: Color(0xFF5B9BD5),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nueva Contraseña',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8EDF3),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Crea una nueva contraseña para\n${emailController.text.trim()}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF8B96A5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        TextField(
          controller: nuevaPasswordController,
          obscureText: _obscureNueva,
          style: const TextStyle(color: Color(0xFFE8EDF3)),
          decoration: _inputDecoration(
            'Nueva contraseña',
            Icons.lock_outline,
            _errorNuevaPassword,
            suffix: IconButton(
              icon: Icon(
                _obscureNueva ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF8B96A5),
              ),
              onPressed: () => setState(() => _obscureNueva = !_obscureNueva),
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
            onPressed: _cargando ? null : _cambiarPassword,
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
                    'Guardar Contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _paso = 1),
          child: const Text(
            '← Cambiar email',
            style: TextStyle(color: Color(0xFF5B9BD5)),
          ),
        ),
      ],
    );
  }
}
