import 'package:flutter/material.dart';

class Detalles extends StatelessWidget {
  final Map<String, dynamic> reporte;

  const Detalles({super.key, required this.reporte});

  Color _colorEstado(String estado) {
    switch (estado) {
      case "Resuelto":
        return Colors.green;
      case "En Proceso":
        return Colors.blue;
      default:
        return Colors.orange;
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
      appBar: AppBar(
        title: const Text('Detalles del Reporte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con icono y tipo
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconoTipo(tipo), size: 60, color: Colors.blue),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tipo.replaceAll("_", " ").toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _colorEstado(estado).withOpacity(0.1),
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

            // Información del reporte
            _seccion('Descripción', descripcion, Icons.description_outlined),
            const SizedBox(height: 16),
            _seccion('Dirección', direccion, Icons.location_on_outlined),
            const SizedBox(height: 16),
            _seccion('Fecha del reporte', fecha, Icons.calendar_today_outlined),

            const SizedBox(height: 28),

            // Contactar soporte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.support_agent, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Contactar soporte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Escríbele al soporte...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.chat_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(contenido, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
