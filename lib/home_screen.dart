import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<DocumentSnapshot?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
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
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: ElevatedButton(
                child: const Text('Iniciar sesión'),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            );
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Nombre: ${userData['nombre'] ?? ''}'),
                Text('Apellido: ${userData['apellido'] ?? ''}'),
                Text('DNI: ${userData['dni'] ?? ''}'),
                Text('Barrio/Zona: ${userData['barrio zona'] ?? ''}'),
                Text('Bio: ${userData['bio'] ?? ''}'),
                const SizedBox(height: 10),
                const Text('Preferencias:'),
                ...((userData['preferencias'] as List<dynamic>? ?? [])
                    .map((pref) => Text('- $pref'))),
                const SizedBox(height: 10),
                Text('Rating y posible match: ${userData['rating y posible match'] ?? 0}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
