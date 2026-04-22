import 'package:flutter/material.dart';

class MenuLaboratorioPage extends StatelessWidget {
  const MenuLaboratorioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratórios de Hardware'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Selecione o componente para teste isolado:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Card de Teste da Câmera
          _buildMenuCard(
            context,
            title: 'Teste de Câmera',
            icon: Icons.camera_alt,
            color: Colors.blue,
            route: '/demo-camera',
          ),

          const SizedBox(height: 12),

          // Card de Teste de Assinatura
          _buildMenuCard(
            context,
            title: 'Teste de Assinatura',
            icon: Icons.gesture,
            color: Colors.green,
            route: '/demo-signature',
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Nota: O objetivo é integrar estes\ncomponentes na Ordem de Serviço da N2.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
