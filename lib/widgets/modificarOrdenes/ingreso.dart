import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto1/servicios/imageService.dart';
import 'package:proyecto1/servicios/orderService.dart';
import 'package:proyecto1/servicios/userService.dart';

class RegistroEquipos extends StatefulWidget {
  const RegistroEquipos({super.key});

  @override
  _RegistroEquiposState createState() => _RegistroEquiposState();
}

class _RegistroEquiposState extends State<RegistroEquipos> {
  final _formKey = GlobalKey<FormState>();
  final OrdenService _ordenService = OrdenService();
  final UsuarioService _usuarioService = UsuarioService();
  final ImageService _imageService = ImageService();
  bool isLoading = false;

  List<File> imagenesSeleccionadas = [];

  int? usuarioIdSeleccionado;
  List<Map<String, dynamic>> usuariosConAcceso = [];

  DateTime fechaHora = DateTime.now();
  String estado = 'Recien llegado';
  List<String> accesoriosSeleccionados = [];

  final List<String> accesoriosOpciones = [
    'Cargador',
    'Mouse',
    'Teclado',
    'Bolso',
    'Otro',
  ];

  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController emailController;
  late TextEditingController modeloController;
  late TextEditingController serieController;
  late TextEditingController estadoController;

  @override
  void initState() {
    super.initState();
    cargarUsuariosConAccesoTotal();

    nombreController = TextEditingController();
    telefonoController = TextEditingController();
    emailController = TextEditingController();
    modeloController = TextEditingController();
    serieController = TextEditingController();
    estadoController = TextEditingController();
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    modeloController.dispose();
    serieController.dispose();
    estadoController.dispose();
    super.dispose();
  }

  Future<void> cargarUsuariosConAccesoTotal() async {
    try {
      final respuesta = await _usuarioService.obtenerUsuarios();
      final filtrados =
          respuesta.where((u) => u['accesoTotal'] == true).toList();

      setState(() {
        usuariosConAcceso = List<Map<String, dynamic>>.from(filtrados);
      });
    } catch (e) {
      print('Error al cargar usuarios: $e');
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fechaHora) {
      setState(() {
        fechaHora = picked;
      });
    }
  }

  Future<void> seleccionarImagenes() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        imagenesSeleccionadas =
            pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<void> guardarOrden() async {
    if (_formKey.currentState!.validate()) {
      if (usuarioIdSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe seleccionar un técnico responsable')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final nombreCliente = nombreController.text.trim();
      final telefonoCliente = int.tryParse(telefonoController.text.trim()) ?? 0;
      final emailCliente = emailController.text.trim();
      final modeloPc = modeloController.text.trim();
      final numeroSeriePc = int.tryParse(serieController.text.trim()) ?? 0;
      final estadoInicial = estadoController.text.trim();

      if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(emailCliente)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingrese un correo electrónico válido')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      String accesoriosEntregados =
          accesoriosSeleccionados.isEmpty
              ? 'NINGUNO'
              : accesoriosSeleccionados.join(', ');

      Map<String, dynamic> nuevaOrden = {
        "usuarioId": usuarioIdSeleccionado,
        "nombreCliente": nombreCliente,
        "telefonoCliente": telefonoCliente,
        "emailCliente": emailCliente,
        "modeloPc": modeloPc,
        "numeroSeriePc": numeroSeriePc,
        "estadoInicial": estadoInicial,
        "estado": estado,
        "accesoriosEntregados": accesoriosEntregados,
      };

      try {
        final respuesta = await _ordenService.crearOrden(nuevaOrden);
        final int ordenId = respuesta['id'];

        for (File imagen in imagenesSeleccionadas) {
          bool exito = await _imageService.subirArchivoImagen(imagen, ordenId);
          if (!exito) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir una imagen')),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Orden creada correctamente con imágenes')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear orden: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estiloInput = InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      labelStyle: const TextStyle(color: Colors.black87),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0B4B30), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ingresar Nueva Orden',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B4B30),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(inputDecorationTheme: estiloInput),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Técnico responsable',
                      ),
                      value: usuarioIdSeleccionado,
                      items:
                          usuariosConAcceso.map((usuario) {
                            return DropdownMenuItem<int>(
                              value: usuario['id'],
                              child: Text(usuario['nombre']),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => usuarioIdSeleccionado = value),
                      validator:
                          (value) =>
                              value == null ? 'Seleccione un técnico' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Ingrese el nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Ingrese el teléfono' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Ingrese el correo' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fecha de ingreso: ${fechaHora.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () => _seleccionarFecha(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4B30),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Seleccionar fecha'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: modeloController,
                      decoration: const InputDecoration(
                        labelText: 'Marca y modelo',
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Ingrese la marca y modelo'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: serieController,
                      decoration: const InputDecoration(
                        labelText: 'Número de serie o ID',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Ingrese el número de serie'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: estadoController,
                      decoration: const InputDecoration(
                        labelText: 'Estado inicial',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: seleccionarImagenes,
                      icon: const Icon(Icons.photo_library),
                      label: const Text(
                        'Seleccionar imágenes',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4B30),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (imagenesSeleccionadas.isNotEmpty)
                      Card(
                        color: Colors.white70,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imagenesSeleccionadas.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    imagenesSeleccionadas[index],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Accesorios entregados',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...accesoriosOpciones.map((item) {
                              return CheckboxListTile(
                                activeColor: const Color(0xFF0B4B30),
                                title: Text(item),
                                value: accesoriosSeleccionados.contains(item),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      accesoriosSeleccionados.add(item);
                                    } else {
                                      accesoriosSeleccionados.remove(item);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(isLoading ? 'Guardando...' : 'Guardar Orden'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : guardarOrden,
                    ),
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
