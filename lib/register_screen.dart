import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final nombre = TextEditingController();
  final apellido = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(controller: apellido, decoration: const InputDecoration(labelText: 'Apellido')),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () async {
              try {
                await auth.register(email.text, pass.text);
                await auth.saveProfile({
                  'nombre': nombre.text,
                  'apellido': apellido.text,
                  'membresia': false,
                });
                Navigator.of(context).pop();
              } catch (e) {
                setState(() => error = e.toString());
              }
            },
            child: const Text('Crear cuenta'),
          ),
        ]),
      ),
    );
  }
}
