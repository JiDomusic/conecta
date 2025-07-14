// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) return const Center(child: Text('Datos no encontrados'));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Nombre: ${data['nombre']}'),
                Text('Apellido: ${data['apellido']}'),
                Text('DNI: ${data['dni']}'),
                Text('Barrio: ${data['barrio zona']}'),
                Text('Bio: ${data['bio']}'),
                const SizedBox(height: 10),
                const Text('Preferencias:'),
                ...List.from(data['preferencias'] ?? []).map((p) => Text('- $p')),
                const SizedBox(height: 10),
                Text('Rating: ${data['rating y posible match']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
