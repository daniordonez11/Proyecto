import 'package:flutter/material.dart';

class RegistroEquipos extends StatefulWidget {
  const RegistroEquipos({super.key});

  @override
  _RegistroEquiposState createState() => _RegistroEquiposState();
}

class _RegistroEquiposState extends State<RegistroEquipos> {
  final _formKey = GlobalKey<FormState>();

  String nombreCliente = '';
  String telefono = '';
  String correo = '';
  DateTime fechaIngreso = DateTime.now();
  String marcaModelo = '';
  String numeroSerie = '';
  String estadoInicial = '';
  List<String> accesorios = [];

  final List<String> accesoriosOpciones = [
    'Cargador',
    'Mouse',
    'Teclado',
    'Bolso',
    'Otro'
  ];

  Future<void> guardarRegistro() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aquí deberías conectar con la base de datos.
      // Por ejemplo: await DBHelper().insertarEquipo(equipo);
      // o registrarEquipo(equipo) para MySQL.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro guardado correctamente')),
      );

      // Opcional: limpiar campos o volver al menú.
    }
  }

  Future<void> _selectFechaIngreso(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaIngreso,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != fechaIngreso) {
      setState(() {
        fechaIngreso = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Equipos'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del cliente'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el nombre' : null,
                onSaved: (value) => nombreCliente = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el teléfono' : null,
                onSaved: (value) => telefono = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el correo' : null,
                onSaved: (value) => correo = value!,
              ),
              SizedBox(height: 16),
              Text('Fecha de ingreso: ${fechaIngreso.toLocal().toString().split(' ')[0]}'),
              ElevatedButton(
                onPressed: () => _selectFechaIngreso(context),
                child: Text('Seleccionar fecha'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Marca y modelo'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese la marca y modelo' : null,
                onSaved: (value) => marcaModelo = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Número de serie o ID'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el número de serie' : null,
                onSaved: (value) => numeroSerie = value!,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Estado inicial (observaciones)'),
                maxLines: 3,
                onSaved: (value) => estadoInicial = value ?? '',
              ),
              SizedBox(height: 16),
              Text('Accesorios entregados'),
              ...accesoriosOpciones.map((item) {
                return CheckboxListTile(
                  title: Text(item),
                  value: accesorios.contains(item),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        accesorios.add(item);
                      } else {
                        accesorios.remove(item);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Guardar'),
                onPressed: guardarRegistro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
