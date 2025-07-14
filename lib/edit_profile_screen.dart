import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _zonaController = TextEditingController();
  final _bioController = TextEditingController();

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      _nombreController.text = data['nombre'] ?? '';
      _apellidoController.text = data['apellido'] ?? '';
      _dniController.text = data['dni'] ?? '';
      _zonaController.text = data['barrio zona'] ?? '';
      _bioController.text = data['bio'] ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'dni': _dniController.text.trim(),
      'barrio zona': _zonaController.text.trim(),
      'bio': _bioController.text.trim(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _zonaController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextFormField(controller: _apellidoController, decoration: const InputDecoration(labelText: 'Apellido')),
              TextFormField(controller: _dniController, decoration: const InputDecoration(labelText: 'DNI')),
              TextFormField(controller: _zonaController, decoration: const InputDecoration(labelText: 'Barrio/Zona')),
              TextFormField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
