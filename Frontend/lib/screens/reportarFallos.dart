import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ReportarFalla extends StatefulWidget {
  final int idUsuario;

  const ReportarFalla({super.key, required this.idUsuario});

  @override
  State<ReportarFalla> createState() => _ReportarFallaState();
}

class _ReportarFallaState extends State<ReportarFalla> {
  String? _tipoFalla;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  bool _cargando = false;
  String? _errorTipo;
  String? _errorDescripcion;
  String? _errorDireccion;

  Future<void> _enviarReporte() async {
    setState(() {
      _errorTipo = null;
      _errorDescripcion = null;
      _errorDireccion = null;
    });
    bool valido = true;
    if (_tipoFalla == null) {
      setState(() => _errorTipo = 'Selecciona un tipo de falla');
      valido = false;
    }
    if (_descripcionController.text.trim().isEmpty) {
      setState(() => _errorDescripcion = 'La descripción es obligatoria');
      valido = false;
    }
    if (_direccionController.text.trim().isEmpty) {
      setState(() => _errorDireccion = 'La dirección es obligatoria');
      valido = false;
    }
    if (!valido) return;

    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse(
        "https://fiberrural-api.onrender.com/crear-reporte",
      );
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "id_usuario": widget.idUsuario,
              "tipo_falla": _tipoFalla,
              "descripcion": _descripcionController.text.trim(),
              "direccion": _direccionController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reporte enviado correctamente"),
            backgroundColor: Color(0xFF4DDD88),
          ),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al enviar el reporte"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de conexión con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Reportar Falla',
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de falla',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8EDF3),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF161B22),
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: InputDecoration(
                errorText: _errorTipo,
                filled: true,
                fillColor: const Color(0xFF161B22),
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
              ),
              hint: const Text(
                'Seleccione una opción',
                style: TextStyle(color: Color(0xFF4A5568)),
              ),
              value: _tipoFalla,
              items: const [
                DropdownMenuItem(
                  value: 'sin_internet',
                  child: Text('Sin Internet'),
                ),
                DropdownMenuItem(
                  value: 'internet_lento',
                  child: Text('Internet Lento'),
                ),
                DropdownMenuItem(
                  value: 'cable_danado',
                  child: Text('Cable Dañado'),
                ),
              ],
              onChanged: (value) => setState(() => _tipoFalla = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8EDF3),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: InputDecoration(
                hintText: 'Escribe aquí el problema...',
                hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                errorText: _errorDescripcion,
                filled: true,
                fillColor: const Color(0xFF161B22),
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
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dirección o referencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8EDF3),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _direccionController,
              style: const TextStyle(color: Color(0xFFE8EDF3)),
              decoration: InputDecoration(
                hintText: 'Ejemplo: Calle 10 #8-15',
                hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                errorText: _errorDireccion,
                filled: true,
                fillColor: const Color(0xFF161B22),
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
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _enviarReporte,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9BD5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enviar reporte',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
