import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nombre;
  late TextEditingController apellido;

  @override
  void initState() {
    super.initState();
    nombre = TextEditingController();
    apellido = TextEditingController();
    context.read<AuthService>().loadProfile().then((data) {
      if (data != null) {
        nombre.text = data['nombre'] ?? '';
        apellido.text = data['apellido'] ?? '';
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: auth.logout),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(controller: apellido, decoration: const InputDecoration(labelText: 'Apellido')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await auth.saveProfile({
                'nombre': nombre.text,
                'apellido': apellido.text,
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
            },
            child: const Text('Guardar'),
          ),
        ]),
      ),
    );
  }
}
