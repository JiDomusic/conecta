import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'community_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      return null;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  Future<List<Map<String, dynamic>>> _getNearbyUsersAndCommunities() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final currentPosition = await _getCurrentLocation();
      final usersQuery = await FirebaseFirestore.instance.collection('users').get();
      final communitiesQuery = await FirebaseFirestore.instance.collection('communities').get();
      
      List<Map<String, dynamic>> results = [];

      // Add nearby users
      for (var doc in usersQuery.docs) {
        if (doc.id == uid) continue;
        
        final data = doc.data();
        final userLat = data['ubicacion']?['latitud'] as double?;
        final userLon = data['ubicacion']?['longitud'] as double?;
        
        double? distance;
        if (currentPosition != null && userLat != null && userLon != null) {
          distance = _calculateDistance(
            currentPosition.latitude, 
            currentPosition.longitude, 
            userLat, 
            userLon
          );
        }

        results.add({
          ...data,
          'id': doc.id,
          'type': 'user',
          'distance_km': distance,
        });
      }

      // Add communities
      for (var doc in communitiesQuery.docs) {
        final data = doc.data();
        results.add({
          ...data,
          'id': doc.id,
          'type': 'community',
        });
      }

      // Sort by distance (users with location first, then communities)
      results.sort((a, b) {
        if (a['distance_km'] != null && b['distance_km'] != null) {
          return (a['distance_km'] as double).compareTo(b['distance_km'] as double);
        } else if (a['distance_km'] != null) {
          return -1;
        } else if (b['distance_km'] != null) {
          return 1;
        } else {
          return 0;
        }
      });

      return results;
    } catch (e) {
      print('Error getting nearby users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFF3E8FF); // lila claro
    final Color cardColor = Colors.white;
    final Color titleColor = const Color(0xFF9C27B0); // lila fuerte

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: titleColor,
        title: const Text('Conecta Rosario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Matches Premium',
            onPressed: () => Navigator.pushNamed(context, '/premium-matches'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getNearbyUsersAndCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('No hay usuarios o comunidades disponibles.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isUser = item['type'] == 'user';
              
              if (isUser) {
                return _buildUserCard(item, cardColor);
              } else {
                return _buildCommunityCard(context, item, cardColor);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, Color cardColor) {
    final nombre = '${user['nombre'] ?? ''} ${user['apellido'] ?? ''}';
    final zona = user['barrio_zona'] ?? user['barrio zona'] ?? '';
    final bio = user['bio'] ?? '';
    final distance = user['distance_km'] as double?;
    
    // Extract preferences from new structure
    final musica = user['musica'] as Map<String, dynamic>?;
    final peliculas = user['peliculas'] as Map<String, dynamic>?;
    final arte = user['arte'] as Map<String, dynamic>?;
    final aficiones = user['aficiones'] as Map<String, dynamic>?;
    
    List<String> allPreferences = [];
    if (musica?['generos'] != null) {
      allPreferences.addAll(List<String>.from(musica!['generos']));
    }
    if (peliculas?['generos'] != null) {
      allPreferences.addAll(List<String>.from(peliculas!['generos']));
    }
    if (arte?['tipos'] != null) {
      allPreferences.addAll(List<String>.from(arte!['tipos']));
    }
    if (aficiones?['deportes'] != null) {
      allPreferences.addAll(List<String>.from(aficiones!['deportes']));
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nombre, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
                if (distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('📍 Zona: $zona', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text('📝 $bio', style: const TextStyle(fontSize: 16)),
            if (allPreferences.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('🎯 Intereses:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: allPreferences.take(6)
                    .map((p) => Chip(
                  label: Text(p, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green.shade100,
                ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, Map<String, dynamic> community, Color cardColor) {
    final nombre = community['nombre'] ?? 'Comunidad';
    final descripcion = community['descripcion'] ?? '';
    final categoria = community['categoria'] ?? '';
    final miembros = List<String>.from(community['miembros'] ?? []);

    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _joinCommunityChat(context, community['id'], nombre),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nombre, 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoria,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('👥 ${miembros.length} miembros', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Text('📝 $descripcion', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                '💬 Toca para unirte al chat comunitario',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _joinCommunityChat(BuildContext context, String communityId, String communityName) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Check if a chat group exists for this community
      final chatQuery = await FirebaseFirestore.instance
          .collection('chat_groups')
          .where('community_id', isEqualTo: communityId)
          .limit(1)
          .get();

      String chatGroupId;
      
      if (chatQuery.docs.isEmpty) {
        // Create new chat group
        final chatDoc = await FirebaseFirestore.instance.collection('chat_groups').add({
          'nombre': 'Chat de $communityName',
          'community_id': communityId,
          'participantes': [currentUser.uid],
          'moderadores': [currentUser.uid],
          'configuracion': {
            'moderacion_ia_activa': true,
            'palabras_permitidas_especiales': ['boludo', 'boluda', 'mierda', 'concha', 'pija', 'culo'],
            'auto_ban_ofensas': true,
          },
          'created_at': FieldValue.serverTimestamp(),
          'last_message_at': FieldValue.serverTimestamp(),
        });
        chatGroupId = chatDoc.id;
      } else {
        // Join existing chat group
        chatGroupId = chatQuery.docs.first.id;
        await FirebaseFirestore.instance
            .collection('chat_groups')
            .doc(chatGroupId)
            .update({
          'participantes': FieldValue.arrayUnion([currentUser.uid])
        });
      }

      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityChatScreen(
            chatGroupId: chatGroupId,
            chatName: 'Chat de $communityName',
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al unirse al chat: $e')),
      );
    }
  }
}
