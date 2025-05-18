import 'package:flutter/material.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({super.key});

  @override
  _CrearUsuarioPageState createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  String nuevoUsuario = '';
  String nuevaContrasena = '';

  void _guardarUsuario() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario creado (simulado)')),
      );

      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nuevo usuario'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el nombre de usuario' : null,
                onSaved: (value) => nuevoUsuario = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese una contraseña' : null,
                onSaved: (value) => nuevaContrasena = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarUsuario,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
