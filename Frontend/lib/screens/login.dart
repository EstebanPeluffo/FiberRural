import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'MenuPrincipal.dart';
import 'RegistroUsuario.dart';
import 'recuperarPassword.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _errorUsuario;
  String? _errorPassword;
  bool _obscurePassword = true;

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF21262D), height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
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
                  Icons.person,
                  size: 40,
                  color: Color(0xFF5B9BD5),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Inicio de Sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8EDF3),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Reporta fallas de tu servicio de Internet',
                style: TextStyle(fontSize: 13, color: Color(0xFF8B96A5)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Usuario
              TextField(
                controller: usuarioController,
                style: const TextStyle(color: Color(0xFFE8EDF3)),
                decoration: InputDecoration(
                  hintText: 'Usuario',
                  hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF8B96A5),
                  ),
                  errorText: _errorUsuario,
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
                ),
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Color(0xFFE8EDF3)),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF8B96A5),
                  ),
                  errorText: _errorPassword,
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF8B96A5),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Olvidaste contraseña centrado
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PantallaOlvidePassword(),
                    ),
                  );
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: Color(0xFF5B9BD5)),
                ),
              ),

              const SizedBox(height: 4),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaRegistro()),
                  );
                },
                child: const Text(
                  'Registrarse',
                  style: TextStyle(color: Color(0xFF5B9BD5)),
                ),
              ),

              const SizedBox(height: 20),

              // Botón iniciar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _errorUsuario = null;
                      _errorPassword = null;
                    });

                    bool valido = true;
                    if (usuarioController.text.isEmpty) {
                      setState(
                        () => _errorUsuario = 'El usuario es obligatorio',
                      );
                      valido = false;
                    }
                    if (passwordController.text.isEmpty) {
                      setState(
                        () => _errorPassword = 'La contraseña es obligatoria',
                      );
                      valido = false;
                    }
                    if (!valido) return;

                    final url = Uri.parse(
                      "https://fiberrural-api.onrender.com/login",
                    );
                    final response = await http
                        .post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "usuario": usuarioController.text,
                            "password": passwordController.text,
                          }),
                        )
                        .timeout(const Duration(seconds: 60));

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('token', data["token"].toString());
                      await prefs.setInt(
                        'idUsuario',
                        int.parse(data["id"].toString()),
                      );
                      await prefs.setString(
                        'usuario',
                        (data["usuario"] ?? "Usuario").toString(),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuPrincipal(
                            usuario: data["usuario"],
                            idUsuario: data["id"],
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Usuario o contraseña incorrectos"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9BD5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
