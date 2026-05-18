import 'package:flutter/material.dart';

class Detalles extends StatelessWidget {
  const Detalles({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Reporte'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          //Textos arriba a la derecha
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 17, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Estado: En Proceso', //TEXTO 1
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reporte realizado el 03 de marzo de 2026', //TEXTO 2
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          //Contenido central (lo dejamos igual)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.support_agent,
                  size: 80,
                  color: Color.fromARGB(255, 243, 170, 33),
                ),
                SizedBox(height: 20),
                Text(
                  'Contacta con el soporte',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Escríbele al soporte',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.chat),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
