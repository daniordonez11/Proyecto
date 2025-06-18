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
    'Cargador',
    'Mouse',
    'Teclado',
    'Bolso',
    'Otro',
  ];

  final List<String> opcionesEstado = [
    "Recien llegado",
    'En proceso',
    'Listo para entrega',
    'Recientemente entregado',
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
      final imgs = await imageService.obtenerImagenesPorOrden(
        widget.orden.id,
      );
      setState(() {
        imagenesOrden = imgs;
        cargandoImagenes = false;
      });
    } catch (e) {
      setState(() {
        cargandoImagenes = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar imágenes: $e')));
    }
  }

  Future<void> _seleccionarYSubirImagen() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final exito = await imageService.subirArchivoImagen(
        file,
        widget.orden.id,
      );
      if (exito) {
        await cargarImagenesDeOrden();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen subida correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen')),
        );
      }
    }
  }

  Future<void> _eliminarImagen(int idImagen) async {
    try {
      await imageService.eliminarImagen(idImagen);
      setState(() {
        imagenesOrden.removeWhere((img) => img['id'] == idImagen);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar imagen: $e')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Orden actualizada correctamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Orden'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.png',
              width: double.infinity, // ancho máximo posible
              height: double.infinity, // alto máximo posible
              fit: BoxFit.fill,
              color: Colors.black.withOpacity(0.5), // opacidad del fondo
              colorBlendMode: BlendMode.darken, // modo de mezcla del color
            ),
          ),
          usuariosConAcceso.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      value: usuarioIdSeleccionado,
                      decoration: InputDecoration(labelText: 'Usuario encargado'),
                      items: usuariosConAcceso.map((usuario) {
                        return DropdownMenuItem<int>(
                          value: usuario.id,
                          child: Text(usuario.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          usuarioIdSeleccionado = value!;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: nombreCliente,
                      decoration: InputDecoration(labelText: 'Nombre del cliente'),
                      validator: (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
                      onSaved: (value) => nombreCliente = value!,
                    ),
                    TextFormField(
                      initialValue: telefono.toString(),
                      decoration: InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Ingrese el teléfono' : null,
                      onSaved: (value) => telefono = int.parse(value!),
                    ),
                    TextFormField(
                      initialValue: correo,
                      decoration: InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty ? 'Ingrese el correo' : null,
                      onSaved: (value) => correo = value!,
                    ),
                    SizedBox(height: 16),
                    Text('Fecha de ingreso: ${fechaIngreso.toLocal().toString().split(' ')[0]}'),
                    ElevatedButton(
                      onPressed: () => _selectFechaIngreso(context),
                      child: Text('Seleccionar fecha'),
                    ),
                    TextFormField(
                      initialValue: marcaModelo,
                      decoration: InputDecoration(labelText: 'Marca y modelo'),
                      validator: (value) => value!.isEmpty ? 'Ingrese la marca y modelo' : null,
                      onSaved: (value) => marcaModelo = value!,
                    ),
                    TextFormField(
                      initialValue: numeroSerie.toString(),
                      decoration: InputDecoration(labelText: 'Número de serie o ID'),
                      validator: (value) => value!.isEmpty ? 'Ingrese el número de serie' : null,
                      onSaved: (value) => numeroSerie = int.parse(value!),
                    ),
                    TextFormField(
                      initialValue: estadoInicial,
                      decoration: InputDecoration(labelText: 'Estado inicial (observaciones)'),
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
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: estado.isNotEmpty ? estado : null,
                      decoration: InputDecoration(
                        labelText: 'Estado de la orden',
                        border: OutlineInputBorder(),
                      ),
                      items: opcionesEstado.map((opcion) {
                        return DropdownMenuItem<String>(
                          value: opcion,
                          child: Text(opcion),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          estado = value!;
                        });
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Seleccione un estado' : null,
                    ),
                    SizedBox(height: 20),
                    Text('Imágenes de la orden'),
                    SizedBox(height: 10),
                    cargandoImagenes
                        ? Center(child: CircularProgressIndicator())
                        : imagenesOrden.isEmpty
                            ? Text('No hay imágenes')
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
                                          margin: EdgeInsets.symmetric(horizontal: 8),
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
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _eliminarImagen(img['id']),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_a_photo),
                      label: Text('Agregar imagen'),
                      onPressed: _seleccionarYSubirImagen,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Guardar cambios'),
                      onPressed: _guardarCambios,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

  }
}
