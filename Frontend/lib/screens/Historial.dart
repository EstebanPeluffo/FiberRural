import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'detalles.dart';

class Historial extends StatefulWidget {
  final int idUsuario;

  const Historial({super.key, required this.idUsuario});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  List<dynamic> _reportes = [];
  bool _cargando = true;

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
        setState(() {
          _reportes = jsonDecode(response.body);
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  int get _total => _reportes.length;
  int get _activos => _reportes.where((r) => r["estado"] != "Resuelto").length;
  int get _resueltos =>
      _reportes.where((r) => r["estado"] == "Resuelto").length;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Mis Reportes',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _metricCard('Total', '$_total', const Color(0xFF5B9BD5)),
                const SizedBox(width: 10),
                _metricCard('Activos', '$_activos', const Color(0xFFF0C000)),
                const SizedBox(width: 10),
                _metricCard(
                  'Resueltos',
                  '$_resueltos',
                  const Color(0xFF4DDD88),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5B9BD5)),
                  )
                : _reportes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 60,
                          color: Color(0xFF8B96A5),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No tienes reportes aún',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B96A5),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Crea tu primer reporte desde el menú principal',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B96A5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reportes.length,
                    itemBuilder: (context, index) {
                      final r = _reportes[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Detalles(reporte: r),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF21262D)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r["tipo_falla"]
                                        .toString()
                                        .replaceAll("_", " ")
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFFE8EDF3),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _colorEstado(
                                        r["estado"],
                                      ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
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
                              const SizedBox(height: 8),
                              Text(
                                r["descripcion"],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8B96A5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Color(0xFF8B96A5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    r["direccion"],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8B96A5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF8B96A5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    r["fecha"].toString().substring(0, 10),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8B96A5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF21262D)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
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
