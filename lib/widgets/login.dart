import 'package:flutter/material.dart';
import 'package:proyecto1/widgets/menu.dart';
//import 'package:proyecto1/widgets/usuario.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String usuario = '';
  String contrasena = '';

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 👇 Aquí deberías validar contra una base de datos o servidor.
      if (usuario == 'admin' && contrasena == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciales inválidas')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Usuario'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el usuario' : null,
                onSaved: (value) => usuario = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese la contraseña' : null,
                onSaved: (value) => contrasena = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: Text('Acceder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
