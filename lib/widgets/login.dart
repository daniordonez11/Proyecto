import 'package:flutter/material.dart';
import 'package:proyecto1/servicios/userService.dart';
import 'package:proyecto1/widgets/menu.dart';
import 'package:proyecto1/widgets/vistaClienteOrdenes/validarOrden.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El appBar puedes dejarlo, o quitar si quieres que la imagen cubra todo
      appBar: AppBar(title: const Text('Iniciar sesión'), centerTitle: true),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
              color: Colors.black.withOpacity(0.5), // Opacidad para el fondo
              colorBlendMode: BlendMode.darken, // Mezcla de color para el fondo
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Image.asset('assets/images/jds.png', height: 150),
                    const SizedBox(height: 50),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ), 
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'ejemplo@correo.com',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0B4B30)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0B4B30)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF0B4B30),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.yellowAccent),
                        filled: true,
                        fillColor: Color(0xFF0B4B30),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Ingrese el correo electrónico'
                                  : null,
                      onSaved: (value) => usuario = value ?? '',
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Contraseña.5',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0B4B30)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0B4B30)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF0B4B30),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.yellowAccent),
                        filled: true,
                        fillColor: Color(0xFF0B4B30),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      obscureText: true,
                      cursorColor: Colors.white,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Ingrese la contraseña' : null,
                      onSaved: (value) => contrasena = value ?? '',
                    ),

                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0B4B30),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.login, size: 28, color: Colors.yellowAccent),
                            label: const Text('Acceder', style: TextStyle(fontSize: 20),),
                            onPressed: _login,
                          ),
                        ),
                    const SizedBox(height: 50), // espacio abajo opcional
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
