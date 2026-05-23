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
            backgroundColor: Colors.green,
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
      appBar: AppBar(
        title: const Text('Reportar Falla'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de falla',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: _errorTipo,
                ),
                hint: const Text('Seleccione una opción'),
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
              const SizedBox(height: 25),
              const Text(
                'Descripción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí el problema...',
                  border: const OutlineInputBorder(),
                  errorText: _errorDescripcion,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dirección o referencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _direccionController,
                decoration: InputDecoration(
                  hintText: 'Ejemplo: Calle 10 #8-15',
                  border: const OutlineInputBorder(),
                  errorText: _errorDireccion,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _cargando ? null : _enviarReporte,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
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
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
