import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/MenuPrincipal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final String? token = prefs.getString('token');
  final String? usuario = prefs.getString('usuario');
  final int? idUsuario = prefs.getInt('idUsuario');

  Widget pantallaInicial;

  if (token != null && token.isNotEmpty) {
    pantallaInicial = MenuPrincipal(
      usuario: usuario ?? "Usuario",
      idUsuario: idUsuario ?? 0,
    );
  } else {
    pantallaInicial = const PantallaInicio();
  }

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
