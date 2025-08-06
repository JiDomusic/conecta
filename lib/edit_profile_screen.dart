import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final preferencias = List<String>.from(data['preferencias'] ?? []);

    final others = await FirebaseFirestore.instance.collection('users').get();
    final posibles = others.docs
        .where((d) => d.id != uid)
        .map((d) {
      final prefs = List<String>.from(d['preferencias'] ?? []);
      final inter = preferencias.toSet().intersection(prefs.toSet());
      if (inter.isNotEmpty) {
        return {
          'nombre': d['nombre'] ?? '',
          'preferencias_comunes': inter.toList(),
        };
      }
      return null;
    })
        .whereType<Map<String, dynamic>>()
        .toList();

    setState(() {
      userData = {
        'uid': uid,
        ...data,
      };
      matches = posibles;
      loading = false;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _editProfile() async {
    await Navigator.pushNamed(context, '/edit-profile');
    _loadProfileData(); // recargar al volver
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF5F0FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF8E24AA),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text('No se encontraron datos del perfil.'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF8E24AA),
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    title: Text(
                      '${userData!['nombre'] ?? ''} ${userData!['apellido'] ?? ''}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(userData!['email'] ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.badge, 'DNI', userData!['dni'] ?? ''),
                  _infoRow(Icons.location_on, 'Zona', userData!['barrio zona'] ?? ''),
                  _infoRow(Icons.info_outline, 'Bio', userData!['bio'] ?? ''),
                  _infoRow(Icons.star_border, 'Rating', '${userData!['rating y posible match'] ?? 0}'),
                  const SizedBox(height: 8),
                  const Text('🎯 Preferencias:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: List<String>.from(userData!['preferencias'] ?? [])
                        .map((p) => Chip(label: Text(p), backgroundColor: Colors.green.shade100))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar perfil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 👑 Cartel de membresías
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '🎉 Membresías disponibles\nDesbloqueá beneficios exclusivos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.amber[800],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/membership');
                  },
                  child: const Text('Ver'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          if (matches.isNotEmpty) ...[
            const Text('🔥 Posibles Matchs:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 10),
            ...matches.map((m) => Card(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pink),
                title: Text(m['nombre']),
                subtitle: Text('Coincidencias: ${m['preferencias_comunes'].join(', ')}'),
              ),
            )),
          ] else
            const Text('Aún no hay coincidencias.'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
