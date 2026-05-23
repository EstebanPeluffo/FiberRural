import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'Historial.dart';
import 'reportarFallos.dart';
import 'detalles.dart';
import 'login.dart';

class MenuPrincipal extends StatefulWidget {
  final String usuario;
  final int idUsuario;

  const MenuPrincipal({
    super.key,
    required this.usuario,
    required this.idUsuario,
  });

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  List<dynamic> _reportesActivos = [];
  int _total = 0;
  int _activos = 0;
  int _resueltos = 0;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "https://fiberrural-api.onrender.com/reportes/${widget.idUsuario}",
      );
      final response = await http
          .get(url, headers: {"Authorization": "Bearer $token"})
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final reportes = jsonDecode(response.body);
        setState(() {
          _total = reportes.length;
          _activos = reportes
              .where((r) => r["estado"] != "Resuelto")
              .toList()
              .length;
          _resueltos = reportes
              .where((r) => r["estado"] == "Resuelto")
              .toList()
              .length;
          _reportesActivos = reportes
              .where((r) => r["estado"] != "Resuelto")
              .toList();
        });
      }
    } catch (e) {
      // Error de conexión
    }
  }

  // ✅ FUNCIÓN: Cerrar Sesión
  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Limpiar datos locales
      await prefs.remove('token');
      await prefs.remove('usuario_id');
      await prefs.remove('usuario');
      await prefs.remove('idUsuario');

      if (!mounted) return;

      // Redirigir a login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicio()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FiberRural'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
      ),
      // ✅ NUEVO: Drawer con menú de 3 rayitas
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header del drawer
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.person, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    widget.usuario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Opciones del menú (aquí tu compañero puede agregar más)
            // ListTile(
            //   leading: const Icon(Icons.home),
            //   title: const Text('Inicio'),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: const Text('Configuración'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Aquí irá la pantalla de configuración
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.help),
            //   title: const Text('Ayuda'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Aquí irá la pantalla de ayuda
            //   },
            // ),
            // Separador
            const Divider(),
            // ✅ SALIR: Texto subrayado al final
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Cierra el drawer primero
                    _cerrarSesion(context);
                  },
                  child: Text(
                    'Salir',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarReportes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, ${widget.usuario}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Reporta fallas de tu servicio de Internet',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _reportesActivos.isEmpty
                  ? Container(
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
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reportes activos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._reportesActivos
                            .map(
                              (r) => GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Detalles(reporte: r),
                                  ),
                                ),
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r["tipo_falla"]
                                                  .toString()
                                                  .replaceAll("_", " ")
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              r["direccion"],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _colorEstado(
                                              r["estado"],
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: _colorEstado(
                                                r["estado"],
                                              ).withOpacity(0.4),
                                            ),
                                          ),
                                          child: Text(
                                            r["estado"],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _colorEstado(r["estado"]),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportarFalla(idUsuario: widget.idUsuario),
                          ),
                        );
                        _cargarReportes();
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
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Historial(idUsuario: widget.idUsuario),
                          ),
                        );
                        _cargarReportes();
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
                    '$_total',
                    Colors.blue.shade50,
                    Colors.blue.shade700,
                  ),
                  const SizedBox(width: 10),
                  _metricCard(
                    'Activos',
                    '$_activos',
                    Colors.orange.shade50,
                    Colors.orange.shade700,
                  ),
                  const SizedBox(width: 10),
                  _metricCard(
                    'Resueltos',
                    '$_resueltos',
                    Colors.green.shade50,
                    Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
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
