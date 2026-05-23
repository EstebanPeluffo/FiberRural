import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para leer el token
import 'screens/login.dart';
import 'screens/MenuPrincipal.dart';

void main() async {
  // 1. Inicializa los servicios nativos de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Abre el almacenamiento local del teléfono
  final prefs = await SharedPreferences.getInstance();

  // 3. Intenta leer el token y los datos guardados
  final String? token = prefs.getString('token');
  final String? usuario = prefs.getString('usuario');
  final int? idUsuario = prefs.getInt('idUsuario');

  // 4. Decidimos la pantalla de inicio: si hay token va al Menú, si no al Login
  Widget pantallaInicial;
  if (token != null && token.isNotEmpty) {
    pantallaInicial = MenuPrincipal(
      usuario: usuario ?? "Usuario",
      idUsuario: idUsuario ?? 0,
    );
  } else {
    pantallaInicial = const PantallaInicio();
  }

  // 5. Arrancamos la aplicación pasándole la pantalla decidida
  runApp(MyApp(pantallaInicial: pantallaInicial));
}

class MyApp extends StatelessWidget {
  final Widget pantallaInicial;

  const MyApp({super.key, required this.pantallaInicial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FiberRural',

      home: pantallaInicial,
    );
  }
}
