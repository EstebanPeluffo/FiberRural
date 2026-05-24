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
    } catch (e) {}
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');
      await prefs.remove('usuario_id');
      await prefs.remove('usuario');
      await prefs.remove('idUsuario');

      if (!mounted) return;

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
        iconTheme: const IconThemeData(color: Color(0xFFE8EDF3)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF21262D), height: 1),
        ),
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF161B22),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1C2A3A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.person, size: 48, color: Color(0xFFE8EDF3)),
                  const SizedBox(height: 8),
                  Text(
                    widget.usuario,
                    style: const TextStyle(
                      color: Color(0xFFE8EDF3),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF30363D)),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _cerrarSesion(context);
                  },
                  child: const Text(
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
                  color: Color(0xFFE8EDF3),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Reporta fallas de tu servicio de Internet',
                style: TextStyle(fontSize: 14, color: Color(0xFF8B96A5)),
              ),

              const SizedBox(height: 20),

              _reportesActivos.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: const Center(
                        child: Text(
                          'No tienes reportes activos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B96A5),
                          ),
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
                            color: Color(0xFFE8EDF3),
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
                                  color: const Color(0xFF161B22),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFF30363D),
                                    ),
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
                                                color: Color(0xFFE8EDF3),
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              r["direccion"],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF8B96A5),
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
                        backgroundColor: const Color(0xFF5B9BD5),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF5B9BD5),
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
                        backgroundColor: const Color(0xFF161B22),
                        foregroundColor: const Color(0xFF5B9BD5),
                        elevation: 4,
                        shadowColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF30363D)),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8EDF3),
                ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8EDF3),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _metricCard(
                    'Total',
                    '$_total',
                    const Color(0xFF161B22),
                    const Color(0xFF5B9BD5),
                  ),

                  const SizedBox(width: 10),

                  _metricCard(
                    'Activos',
                    '$_activos',
                    const Color(0xFF161B22),
                    Colors.orange,
                  ),

                  const SizedBox(width: 10),

                  _metricCard(
                    'Resueltos',
                    '$_resueltos',
                    const Color(0xFF161B22),
                    Colors.green,
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
          const Icon(Icons.circle, color: Color(0xFF5B9BD5), size: 10),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFFE8EDF3)),
            ),
          ),

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
          border: Border.all(color: const Color(0xFF30363D)),
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

            const Text(''),

            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B96A5)),
            ),
          ],
        ),
      ),
    );
  }
}
