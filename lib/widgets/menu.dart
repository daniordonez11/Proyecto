import 'package:flutter/material.dart';
import 'package:proyecto1/widgets/ingreso.dart';
import 'package:proyecto1/widgets/ordenes.dart';
import 'package:proyecto1/widgets/buscar.dart';  // importa la nueva pantalla de búsqueda

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
