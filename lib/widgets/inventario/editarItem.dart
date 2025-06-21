import 'package:flutter/material.dart';
import 'package:proyecto1/clases/item.dart';
import 'package:proyecto1/servicios/itemService.dart';
import 'package:proyecto1/stream/stream.dart';

class EditarItemPage extends StatefulWidget {
  final Inventario item;

  const EditarItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditarItemPageState createState() => _EditarItemPageState();
}

class _EditarItemPageState extends State<EditarItemPage> {
  late int cantidad;
  late TextEditingController observacionController;
  final ItemService itemService = ItemService();

  final OrdenInventarioNotifier notifier = OrdenInventarioNotifier();

  @override
  void initState() {
    super.initState();
    cantidad = widget.item.cantidad;
    observacionController = TextEditingController(text: widget.item.observacion);
  }

  @override
  void dispose() {
    observacionController.dispose();
    super.dispose();
  }

  Future<void> guardarCambios() async {
    final data = {
      'cantidad': cantidad,
      'observacion': observacionController.text.trim(),
    };

    try {
      await itemService.actualizarItem(widget.item.id, data);

      await notifier.actualizarInventario();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ítem actualizado correctamente')),
      );
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Ítem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(widget.item.descripcion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: cantidad > 0 ? () => setState(() => cantidad--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$cantidad', style: const TextStyle(fontSize: 20)),
                IconButton(
                  onPressed: () => setState(() => cantidad++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: observacionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: guardarCambios,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4B30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
