import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto1/clases/orden.dart';
import 'package:proyecto1/clases/usuario.dart';
import 'package:proyecto1/servicios/imageService.dart';
import 'package:proyecto1/servicios/orderService.dart';
import 'package:proyecto1/servicios/userService.dart';

class editarOrden extends StatefulWidget {
  final Orden orden;

  const editarOrden({super.key, required this.orden});

  @override
  _editarOrdenState createState() => _editarOrdenState();
}

class _editarOrdenState extends State<editarOrden> {
  final _formKey = GlobalKey<FormState>();
  final OrdenService _ordenService = OrdenService();
  final UsuarioService _usuarioService = UsuarioService();
  final ImageService imageService = ImageService();
  final ImagePicker _picker = ImagePicker();

  late String nombreCliente;
  late int telefono;
  late String correo;
  late DateTime fechaIngreso;
  late String marcaModelo;
  late int numeroSerie;
  late String estadoInicial;
  late List<String> accesorios;
  late int usuarioIdSeleccionado;
  late String estado;

  List<Usuario> usuariosConAcceso = [];
  List<dynamic> imagenesOrden = [];
  bool cargandoImagenes = true;

  final List<String> accesoriosOpciones = [
    'Cargador', 'Mouse', 'Teclado', 'Bolso'
  ];

  final List<String> opcionesEstado = [
    "Recien llegado", 'En proceso', 'Listo para entrega', 'Recientemente entregado',
  ];

  @override
  void initState() {
    super.initState();
    final orden = widget.orden;
    nombreCliente = orden.nombreCliente;
    telefono = orden.telefonoCliente;
    correo = orden.emailCliente;
    fechaIngreso = orden.fechaHora;
    marcaModelo = orden.modeloPc;
    numeroSerie = orden.numeroSeriePc;
    estadoInicial = orden.estadoInicial;
    accesorios = orden.accesoriosEntregados
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    usuarioIdSeleccionado = orden.usuarioId;
    estado = orden.estado;

    cargarUsuariosConAcceso();
    cargarImagenesDeOrden();
  }

  Future<void> cargarUsuariosConAcceso() async {
    final usuariosJson = await _usuarioService.obtenerUsuarios();
    final lista = usuariosJson
        .where((u) => u['accesoTotal'] == true)
        .map((u) => Usuario.fromJson(u))
        .toList();

    setState(() {
      usuariosConAcceso = lista;
      final existe = lista.any((u) => u.id == usuarioIdSeleccionado);
      if (!existe && lista.isNotEmpty) {
        usuarioIdSeleccionado = lista.first.id;
      }
    });
  }

  Future<void> cargarImagenesDeOrden() async {
    try {
      final imgs = await imageService.obtenerImagenesPorOrden(widget.orden.id);
      setState(() {
        imagenesOrden = imgs;
        cargandoImagenes = false;
      });
    } catch (e) {
      setState(() {
        cargandoImagenes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar imágenes: $e')));
    }
  }

  Future<void> _seleccionarYSubirImagen() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final exito = await imageService.subirArchivoImagen(file, widget.orden.id);
      if (exito) {
        await cargarImagenesDeOrden();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imagen subida correctamente')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir imagen')));
      }
    }
  }

  Future<void> _eliminarImagen(int idImagen) async {
    try {
      await imageService.eliminarImagen(idImagen);
      setState(() {
        imagenesOrden.removeWhere((img) => img['id'] == idImagen);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imagen eliminada')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar imagen: $e')));
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final data = {
        'usuarioId': usuarioIdSeleccionado,
        'nombreCliente': nombreCliente,
        'telefonoCliente': telefono,
        'emailCliente': correo,
        'fechaHora': fechaIngreso.toIso8601String(),
        'modeloPc': marcaModelo,
        'numeroSeriePc': numeroSerie,
        'estadoInicial': estadoInicial,
        'accesoriosEntregados': accesorios.join(', '),
        'estado': estado,
      };

      try {
        await _ordenService.actualizarOrden(widget.orden.id, data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Orden actualizada correctamente')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _selectFechaIngreso(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaIngreso,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fechaIngreso = picked;
      });
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
        title: const Text('Editar Orden'),
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
            child: usuariosConAcceso.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(labelText: 'Usuario encargado'),
                            value: usuarioIdSeleccionado,
                            items: usuariosConAcceso.map((usuario) {
                              return DropdownMenuItem<int>(
                                value: usuario.id,
                                child: Text(usuario.nombre),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => usuarioIdSeleccionado = value!),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: nombreCliente,
                            decoration: const InputDecoration(labelText: 'Nombre del cliente'),
                            validator: (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
                            onSaved: (value) => nombreCliente = value!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: telefono.toString(),
                            decoration: const InputDecoration(labelText: 'Teléfono'),
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.isEmpty ? 'Ingrese el teléfono' : null,
                            onSaved: (value) => telefono = int.parse(value!),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: correo,
                            decoration: const InputDecoration(labelText: 'Correo electrónico'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.isEmpty ? 'Ingrese el correo' : null,
                            onSaved: (value) => correo = value!,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fecha de ingreso: ${fechaIngreso.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              ElevatedButton(
                                onPressed: () => _selectFechaIngreso(context),
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
                            initialValue: marcaModelo,
                            decoration: const InputDecoration(labelText: 'Marca y modelo'),
                            validator: (value) => value!.isEmpty ? 'Ingrese la marca y modelo' : null,
                            onSaved: (value) => marcaModelo = value!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: numeroSerie.toString(),
                            decoration: const InputDecoration(labelText: 'Número de serie o ID'),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Ingrese el número de serie' : null,
                            onSaved: (value) => numeroSerie = int.parse(value!),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: estadoInicial,
                            decoration: const InputDecoration(labelText: 'Estado inicial (observaciones)'),
                            maxLines: 3,
                            onSaved: (value) => estadoInicial = value ?? '',
                          ),
                          const SizedBox(height: 20),
                          Card(
                            color: Colors.white.withOpacity(0.9),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: accesoriosOpciones.map((item) {
                                  return CheckboxListTile(
                                    activeColor: const Color(0xFF0B4B30),
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: estado.isNotEmpty ? estado : null,
                            decoration: const InputDecoration(labelText: 'Estado de la orden'),
                            items: opcionesEstado.map((opcion) {
                              return DropdownMenuItem<String>(
                                value: opcion,
                                child: Text(opcion),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => estado = value!),
                            validator: (value) => value == null || value.isEmpty ? 'Seleccione un estado' : null,
                          ),
                          const SizedBox(height: 16),
                          const Text('Imágenes de la orden', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          cargandoImagenes
                              ? const Center(child: CircularProgressIndicator())
                              : imagenesOrden.isEmpty
                                  ? const Text('No hay imágenes', style: TextStyle(color: Colors.white70))
                                  : SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imagenesOrden.length,
                                        itemBuilder: (context, index) {
                                          final img = imagenesOrden[index];
                                          return Stack(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Image.network(
                                                  img['urlImagen'],
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _eliminarImagen(img['id']),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Agregar imagen'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4B30), foregroundColor: Colors.white,),
                            onPressed: _seleccionarYSubirImagen,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar cambios'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4B30),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _guardarCambios,
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
