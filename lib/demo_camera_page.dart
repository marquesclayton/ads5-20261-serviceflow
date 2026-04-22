import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DemoCameraPage extends StatefulWidget {
  const DemoCameraPage({super.key});

  @override
  State<DemoCameraPage> createState() => _DemoCameraPageState();
}

class _DemoCameraPageState extends State<DemoCameraPage> {
  // Variável que guardará o arquivo da foto
  XFile? _fotoCapturada;
  final ImagePicker _picker = ImagePicker();

  // Função assíncrona para abrir a câmera
  Future<void> _tirarFoto() async {
    try {
      // Abre a câmera nativa
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear, // Câmera traseira
        imageQuality: 80, // Comprime a foto para economizar espaço
      );

      // Se o usuário tirou a foto (não cancelou)
      if (photo != null) {
        setState(() {
          _fotoCapturada = photo;
        });
        print('Foto salva em: ${photo.path}'); // Para debug no console
      }
    } catch (e) {
      print('Erro ao abrir câmera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab: Teste de Câmera')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Área de Preview da Foto
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[100],
              ),
              child: _fotoCapturada == null
                  ? const Center(child: Text('Nenhuma foto capturada'))
                  : Image.file(
                      // Converte XFile path para File
                      File(_fotoCapturada!.path),
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 30),

            // Botão de Ação
            ElevatedButton.icon(
              onPressed: _tirarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('ABRIR CÂMERA'),
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),

            if (_fotoCapturada != null)
              TextButton(
                onPressed: () => setState(() => _fotoCapturada = null),
                child: const Text('Limpar Foto',
                    style: TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}
