import 'package:flutter/material.dart';
import 'package:proyecto1/servicios/userService.dart';
import 'package:proyecto1/widgets/menu.dart';
import 'package:proyecto1/widgets/validarOrden.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
  
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String usuario = '';
  String contrasena = '';

  final UsuarioService usuarioService = UsuarioService();

  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        final usuarios = await usuarioService.obtenerUsuarios();

        var usuarioEncontrado = usuarios.firstWhere(
          (u) => u['email'] == usuario.trim(),
          orElse: () => null,
        );

        if (usuarioEncontrado == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado')),
          );
          setState(() => _isLoading = false);
          return;
        }

        if (usuarioEncontrado["contrasena"] == contrasena.trim()) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('usuarioId', usuarioEncontrado['id']);
          await prefs.setBool('accesoTotal', usuarioEncontrado['accesoTotal']);
          await prefs.setString('nombre', usuarioEncontrado['nombre']);
          if (usuarioEncontrado['accesoTotal'] == true) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
          );
          } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ValidarOrdenPage()),
          );   
        }

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña incorrecta')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/images/jds.png',
                height: 150,
              ),
              SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el correo electrónico' : null,
                onSaved: (value) => usuario = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese la contraseña' : null,
                onSaved: (value) => contrasena = value ?? '',
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Acceder'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}