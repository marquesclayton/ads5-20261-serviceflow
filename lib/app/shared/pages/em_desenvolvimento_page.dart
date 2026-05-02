import 'package:flutter/material.dart';

class EmDesenvolvimentoPage extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color cor;
  final String descricao;

  const EmDesenvolvimentoPage({
    super.key,
    required this.titulo,
    required this.icone,
    this.cor = Colors.grey,
    this.descricao = 'Esta funcionalidade está em desenvolvimento',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: cor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}