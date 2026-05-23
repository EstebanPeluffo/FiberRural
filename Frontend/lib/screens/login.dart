import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:async';
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
  bool _mostrarContrasena = false; // ✅ NUEVO: Variable para mostrar/ocultar

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Inicio de Sesion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: usuarioController,
                decoration: InputDecoration(
                  hintText: 'Usuario',
                  border: const OutlineInputBorder(),
                  errorText: _errorUsuario,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ✅ MODIFICADO: TextField de contraseña con ojito
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: passwordController,
                obscureText:
                    !_mostrarContrasena, // Mostrar u ocultar según el estado
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  errorText: _errorPassword,
                  // ✅ NUEVO: Agregar icono de ojo al final
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarContrasena
                          ? Icons
                                .visibility // Ojo abierto
                          : Icons.visibility_off, // Ojo cerrado
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarContrasena = !_mostrarContrasena;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaOlvidePassword(),
                  ),
                );
              },
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaRegistro()),
                );
              },
              child: const Text("Registrarse"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorUsuario = null;
                  _errorPassword = null;
                });

                bool valido = true;
                if (usuarioController.text.isEmpty) {
                  setState(() => _errorUsuario = 'El usuario es obligatorio');
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

                  // Guardar token
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
                backgroundColor: Colors.blue,
                elevation: 8,
              ),
              child: const Text(
                'Iniciar Sesion',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Reporta fallas de tu servicio de Internet'),
          ],
        ),
      ),
    );
  }
}
