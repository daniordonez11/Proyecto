import 'package:flutter/material.dart';
import 'package:proyecto1/servicios/orderService.dart';
import 'package:proyecto1/widgets/detalleOrden.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValidarOrdenPage extends StatefulWidget {
  @override
  _ValidarOrdenPageState createState() => _ValidarOrdenPageState();
}

class _ValidarOrdenPageState extends State<ValidarOrdenPage> {
  final TextEditingController _idController = TextEditingController();
  final OrdenService ordenService = OrdenService(); // Debes tener este servicio implementado
  String? _mensaje;

  void _verificarOrden() async {
    final prefs = await SharedPreferences.getInstance();
    final int? usuarioId = prefs.getInt('usuarioId');
    final idIngresado = int.tryParse(_idController.text.trim());

    if (usuarioId == null || idIngresado == null) {
      setState(() => _mensaje = 'Datos inválidos');
      return;
    }

    try {
      final ordenes = await ordenService.obtenerOrdenes();
      final orden = ordenes.firstWhere(
        (o) => o['id'] == idIngresado && o['usuarioId'] == usuarioId,
        orElse: () => null,
      );

      if (orden == null) {
        setState(() => _mensaje = 'Orden no encontrada o no pertenece al usuario');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DetalleOrdenPage(orden: orden)),
        );
      }
    } catch (e) {
      setState(() => _mensaje = 'Error al consultar ordenes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Validar Orden')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Ingrese el ID de su orden para continuar:'),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'ID de Orden'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verificarOrden,
              child: Text('Validar'),
            ),
            if (_mensaje != null) ...[
              SizedBox(height: 20),
              Text(_mensaje!, style: TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
