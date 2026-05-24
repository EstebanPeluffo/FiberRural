import 'package:flutter/material.dart';

class Detalles extends StatelessWidget {
  final Map<String, dynamic> reporte;

  const Detalles({super.key, required this.reporte});

  Color _colorEstado(String estado) {
    switch (estado) {
      case "Resuelto":
        return const Color(0xFF4DDD88);
      case "En Proceso":
        return const Color(0xFF5B9BD5);
      default:
        return const Color(0xFFF0C000);
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case "sin_internet":
        return Icons.wifi_off;
      case "internet_lento":
        return Icons.speed;
      case "cable_danado":
        return Icons.cable;
      default:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = reporte["estado"] ?? "Pendiente";
    final tipo = reporte["tipo_falla"] ?? "";
    final descripcion = reporte["descripcion"] ?? "";
    final direccion = reporte["direccion"] ?? "";
    final fecha = reporte["fecha"]?.toString().substring(0, 10) ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Detalles del Reporte',
          style: TextStyle(
            color: Color(0xFF5B9BD5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5B9BD5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF21262D), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C2A3A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconoTipo(tipo),
                      size: 60,
                      color: const Color(0xFF5B9BD5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tipo.replaceAll("_", " ").toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8EDF3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _colorEstado(estado).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _colorEstado(estado).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        fontSize: 14,
                        color: _colorEstado(estado),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _seccion('Descripción', descripcion, Icons.description_outlined),
            const SizedBox(height: 12),
            _seccion('Dirección', direccion, Icons.location_on_outlined),
            const SizedBox(height: 12),
            _seccion('Fecha del reporte', fecha, Icons.calendar_today_outlined),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF21262D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.support_agent, color: Color(0xFF5B9BD5)),
                      SizedBox(width: 8),
                      Text(
                        'Contactar soporte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE8EDF3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(color: Color(0xFFE8EDF3)),
                    decoration: InputDecoration(
                      hintText: 'Escríbele al soporte...',
                      hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                      filled: true,
                      fillColor: const Color(0xFF0D1117),
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
                      prefixIcon: const Icon(
                        Icons.chat_outlined,
                        color: Color(0xFF8B96A5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B9BD5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Enviar mensaje',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, String contenido, IconData icono) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFF5B9BD5), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B96A5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contenido,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFE8EDF3),
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
