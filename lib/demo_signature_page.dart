import 'dart:typed_data'; // Necessário para Uint8List
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class DemoSignaturePage extends StatefulWidget {
  const DemoSignaturePage({super.key});

  @override
  State<DemoSignaturePage> createState() => _DemoSignaturePageState();
}

class _DemoSignaturePageState extends State<DemoSignaturePage> {
  // Controlador que gerencia o canvas
  late SignatureController _controller;

  // Variável para armazenar a imagem da assinatura gerada (para preview)
  Uint8List? _signatureBytes;

  @override
  void initState() {
    super.initState();
    // Inicializa o controlador com configurações de estilo
    _controller = SignatureController(
      penStrokeWidth: 4, // Espessura da caneta
      penColor: Colors.blue, // Cor da caneta
      exportBackgroundColor: Colors.white, // Fundo ao exportar
    );
  }

  @override
  void dispose() {
    // Importante: Dispose do controller para evitar vazamento de memória
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportarAssinatura() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, assine antes de confirmar.')),
      );
      return;
    }

    // Converte o desenho em dados binários (PNG)
    final Uint8List? bytes = await _controller.toPngBytes();

    setState(() {
      _signatureBytes = bytes;
    });

    print('Assinatura exportada como ${bytes?.length} bytes.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab: Teste de Assinatura')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Assine no campo abaixo:',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // --- O CANVAS DE ASSINATURA ---
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Signature(
                controller: _controller,
                height: 250,
                backgroundColor: Colors.grey[100]!,
              ),
            ),

            // Botões de Controle do Canvas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _controller.clear(),
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: _exportarAssinatura,
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar Assinatura'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Divider(),

            // --- ÁREA DE PREVIEW DO RESULTADO (Simulando Salvar) ---
            if (_signatureBytes != null) ...[
              const Text('Preview da Assinatura Salva (Binário):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                // Exibe a imagem a partir dos bytes na memória
                child: Image.memory(_signatureBytes!, height: 100),
              ),
              const SizedBox(height: 10),
              const Text(
                'Na próxima aula, aprenderemos a salvar esses bytes no Hive.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              )
            ]
          ],
        ),
      ),
    );
  }
}
