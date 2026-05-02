import 'package:flutter/material.dart';

class TestIconsPage extends StatelessWidget {
  const TestIconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Ícones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teste de Ícones Básicos do Flutter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Se você vê "X" nos ícones abaixo, há um problema:'),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildIconTest('Home', Icons.home),
                  _buildIconTest('Add', Icons.add),
                  _buildIconTest('Search', Icons.search),
                  _buildIconTest('People', Icons.people),
                  _buildIconTest('Build', Icons.build),
                  _buildIconTest('Settings', Icons.settings),
                  _buildIconTest('Logout', Icons.logout),
                  _buildIconTest('Check', Icons.check),
                  _buildIconTest('Star', Icons.star),
                  _buildIconTest('Heart', Icons.favorite),
                  _buildIconTest('Phone', Icons.phone),
                  _buildIconTest('Email', Icons.email),
                  _buildIconTest('Camera', Icons.camera_alt),
                  _buildIconTest('Bar Chart', Icons.bar_chart),
                  _buildIconTest('Science', Icons.science),
                  _buildIconTest('Pending', Icons.pending_actions),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTest(String label, IconData icon) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
