import 'package:flutter/material.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF3E8FF); // Lila claro
    final Color gold = const Color(0xFFFFD700);
    final Color accent = Colors.deepPurple;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Membresías Conecta'),
        backgroundColor: accent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            '✨ Bienvenido a Conecta Premium',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aquí valoramos la conexión auténtica, la empatía y el respeto.\n\nNuestra membresía está pensada para quienes desean contribuir activamente a la comunidad y acceder a experiencias más enriquecedoras.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildMembershipCard(
            title: 'Plan Gratuito',
            color: Colors.white,
            price: 'Gratis',
            features: const [
              '✅ Crear perfil',
              '✅ Ver usuarios',
              '✅ Enviar me gusta',
            ],
          ),
          const SizedBox(height: 16),
          _buildMembershipCard(
            title: 'Plan Comunidad',
            color: gold,
            price: '\$350/mes',
            features: const [
              '💬 Enviar mensajes ilimitados',
              '👀 Ver quién te vio',
              '🌟 Aparecer primero en resultados',
              '🎁 Acceso a encuentros mensuales (presencial u online)',
            ],
            highlight: true,
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver al perfil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard({
    required String title,
    required Color color,
    required String price,
    required List<String> features,
    bool highlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: highlight ? Colors.black26 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.white : Colors.black87,
              )),
          const SizedBox(height: 8),
          Text(price,
              style: TextStyle(
                fontSize: 18,
                color: highlight ? Colors.white : Colors.black54,
              )),
          const SizedBox(height: 12),
          ...features.map(
                (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: highlight ? Colors.white : Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        color: highlight ? Colors.white : Colors.black87,
                      ),
                    ),
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
