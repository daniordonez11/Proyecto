# proyecto1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

menu

import 'package:flutter/material.dart';
import 'package:proyecto1/servicios/userService.dart';
import 'package:proyecto1/widgets/ingreso.dart';
import 'package:proyecto1/widgets/ordenes.dart';
import 'package:proyecto1/widgets/buscar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int?> obtenerUsuarioId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('usuarioId');
} 

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<bool?> obtenerAccesoTotal() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('accesoTotal');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'assets/images/jds.png',
                height: 100,
              ),
              SizedBox(height: 100),
            ElevatedButton.icon(
              icon: Icon(Icons.computer),
              label: Text('Registrar equipo'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroEquipos()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.list_alt),
              label: Text('Clasificacion de Ordenes'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerOrdenesPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.search),
              label: Text('Buscar Orden'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuscarOrdenPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

