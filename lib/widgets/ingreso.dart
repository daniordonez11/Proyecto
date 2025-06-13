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

  // Controladores de texto
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

      // Obtener valores desde los controladores
      final nombreCliente = nombreController.text;
      final telefonoCliente = int.tryParse(telefonoController.text) ?? 0;
      final emailCliente = emailController.text;
      final modeloPc = modeloController.text;
      final numeroSeriePc = int.tryParse(serieController.text) ?? 0;
      final estadoInicial = estadoController.text;

      String accesoriosEntregados = accesoriosSeleccionados.isEmpty
          ? 'NINGUNO'
          : accesoriosSeleccionados.join(', ');

      Map<String, dynamic> nuevaOrden = {
        "usuarioId": usuarioIdSeleccionado,
        "nombreCliente": nombreCliente,
        "telefonoCliente": telefonoCliente,
        "emailCliente": emailCliente,
        "fechaHora": fechaHora.toIso8601String(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear orden: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingresar Nueva Orden'),
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
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Técnico responsable'),
                value: usuarioIdSeleccionado,
                items: usuariosConAcceso.map((usuario) {
                  return DropdownMenuItem<int>(
                    value: usuario['id'],
                    child: Text(usuario['nombre']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    usuarioIdSeleccionado = value;
                  });
                },
                validator:
                    (value) => value == null ? 'Seleccione un técnico' : null,
              ),
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre del cliente'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
              ),
              TextFormField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Ingrese el teléfono' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) => value!.isEmpty ? 'Ingrese el correo' : null,
              ),
              SizedBox(height: 16),
              Text(
                'Fecha de ingreso: ${fechaHora.toLocal().toString().split(' ')[0]}',
              ),
              ElevatedButton(
                onPressed: () => _seleccionarFecha(context),
                child: Text('Seleccionar fecha'),
              ),
              TextFormField(
                controller: modeloController,
                decoration: InputDecoration(labelText: 'Marca y modelo'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese la marca y modelo' : null,
              ),
              TextFormField(
                controller: serieController,
                decoration: InputDecoration(labelText: 'Número de serie o ID'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Ingrese el número de serie' : null,
              ),
              TextFormField(
                controller: estadoController,
                decoration: InputDecoration(labelText: 'Estado inicial'),
                maxLines: 3,
              ),
              ElevatedButton.icon(
                onPressed: seleccionarImagenes,
                icon: Icon(Icons.photo_library),
                label: Text('Seleccionar imágenes'),
              ),
              imagenesSeleccionadas.isEmpty
                  ? Text('No hay imágenes seleccionadas')
                  : SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imagenesSeleccionadas.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(imagenesSeleccionadas[index]),
                          );
                        },
                      ),
                    ),
              SizedBox(height: 16),
              Text('Accesorios entregados'),
              ...accesoriosOpciones.map((item) {
                return CheckboxListTile(
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
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Guardar Orden'),
                onPressed: guardarOrden,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
