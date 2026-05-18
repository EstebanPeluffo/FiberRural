import 'package:flutter/material.dart';

import 'screens/login.dart';
//import 'screens/reportarFallos.dart';
//import 'screens/detalles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Proyecto',

      // las tres pantallas son las siguientes:
      home: PantallaInicio(),
      //home: const ReportarFalla(),
      //home: const Detalles(),
    );
  }
}
