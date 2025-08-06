import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return {
      'uid': user.uid,
      'email': user.email ?? '',
      ...doc.data()!,
    };
  }

  Future<List<Map<String, dynamic>>> _getMatchCandidates(List<String> preferencias, String myUid) async {
    final query = await FirebaseFirestore.instance.collection('users').get();

    return query.docs
        .where((doc) => doc.id != myUid)
        .map((doc) {
      final prefs = List<String>.from(doc['preferencias'] ?? []);
      final intersect = preferencias.toSet().intersection(prefs.toSet());
      if (intersect.isNotEmpty) {
        return {
          'nombre': doc['nombre'] ?? '',
          'preferencias_comunes': intersect.toList(),
        };
      }
      return null;
    })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _goToAuth(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF8E24AA),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, userSnap) {
          if (userSnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = userSnap.data;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aún no te registraste.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _goToAuth(context),
                    child: const Text('Iniciar sesión o registrarse'),
                  ),
                ],
              ),
            );
          }

          final preferencias = List<String>.from(data['preferencias'] ?? []);
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getMatchCandidates(preferencias, data['uid']),
            builder: (context, matchSnap) {
              final matchs = matchSnap.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF8E24AA),
                              child: Icon(Icons.person, size: 32, color: Colors.white),
                            ),
                            title: Text(
                              '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(data['email'] ?? ''),
                          ),
                          const SizedBox(height: 12),
                          _infoRow(Icons.badge, 'DNI', data['dni'] ?? ''),
                          _infoRow(Icons.location_on, 'Barrio/Zona', data['barrio zona'] ?? ''),
                          _infoRow(Icons.info_outline, 'Bio', data['bio'] ?? ''),
                          _infoRow(Icons.star_border, 'Rating', '${data['rating'] ?? 0}'),
                          const SizedBox(height: 12),
                          
                          // Música section
                          _buildPreferenceSection('🎵 Música', data['musica']),
                          
                          // Películas section
                          _buildPreferenceSection('🎬 Películas & Series', data['peliculas']),
                          
                          // Arte section  
                          _buildPreferenceSection('🎨 Arte & Cultura', data['arte']),
                          
                          // Aficiones section
                          _buildPreferenceSection('🏃 Aficiones & Hobbies', data['aficiones']),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar Perfil'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _logout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text('Cerrar sesión'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 👑 Cartel dorado de membresías
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

                  const SizedBox(height: 24),
                  if (matchs.isNotEmpty) ...[
                    const Text('🔥 Posibles Matchs:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                    const SizedBox(height: 10),
                    ...matchs.map((m) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.pink),
                        title: Text(m['nombre']),
                        subtitle: Text('Coincidencias: ${m['preferencias_comunes'].join(', ')}'),
                      ),
                    )),
                  ] else
                    const Center(child: Text('No hay coincidencias aún.')),
                ],
              );
            },
          );
        },
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

  Widget _buildPreferenceSection(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('No especificado', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          ...data.entries.map((entry) {
            if (entry.value is List && (entry.value as List).isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('${_capitalizeFirst(entry.key)}: ${(entry.value as List).join(", ")}'),
              );
            } else if (entry.value is bool) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('${_capitalizeFirst(entry.key)}: ${entry.value ? "Sí" : "No"}'),
              );
            } else if (entry.value is String && entry.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('${_capitalizeFirst(entry.key)}: ${entry.value}'),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');
  }
}
