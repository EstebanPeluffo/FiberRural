import 'package:flutter/material.dart';
import 'Historial.dart';
import 'reportarFallos.dart';

class MenuPrincipal extends StatelessWidget {
  final String usuario;
  final int idUsuario;

  const MenuPrincipal({
    super.key,
    required this.usuario,
    required this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FiberRural'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, $usuario',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Reporta fallas de tu servicio de Internet',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Center(
                child: Text(
                  'No tienes reportes activos',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportarFalla(idUsuario: idUsuario),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nuevo reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Historial(idUsuario: idUsuario),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Mis reportes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Estado del servicio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _estadoItem(
              Icons.wifi,
              'Conexión principal',
              'Activo',
              Colors.green,
            ),
            _estadoItem(
              Icons.speed,
              'Velocidad de bajada',
              'Estable',
              Colors.orange,
            ),
            _estadoItem(
              Icons.support_agent,
              'Soporte técnico',
              'Disponible',
              Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Resumen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _metricCard(
                  'Total',
                  '0',
                  Colors.blue.shade50,
                  Colors.blue.shade700,
                ),
                const SizedBox(width: 10),
                _metricCard(
                  'Activos',
                  '0',
                  Colors.orange.shade50,
                  Colors.orange.shade700,
                ),
                const SizedBox(width: 10),
                _metricCard(
                  'Resueltos',
                  '0',
                  Colors.green.shade50,
                  Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoItem(IconData icon, String label, String estado, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            estado,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
