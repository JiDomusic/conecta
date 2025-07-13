import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: auth.loadProfile(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          final nombre = data['nombre'] ?? '';
          final premi = data['membresia'] ?? false;
          return Stack(
            children: [
              Container(color: Colors.white),
              Center(child: Text('Bienvenide, $nombre', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
              if (!premi)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí se integrará el pago con MercadoPago o Stripe
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                      child: const Text('Activar Membresía Premium (USD 3)'),
                    ),
                  ),
                ),
              Positioned(
                top: 48, right: 16,
                child: IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
