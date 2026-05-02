import 'package:flutter/material.dart';

mixin LoaderMixin {
  bool _isLoaderOpen = false;

  void showLoading(BuildContext context) {
    if (_isLoaderOpen) return;
    _isLoaderOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar ao clicar fora
      builder: (context) {
        return PopScope(
          canPop: false, // Impede fechar pelo botão voltar do Android
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min, // Usa apenas o espaço necessário
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Carregando...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void hideLoading(BuildContext context) {
    if (_isLoaderOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoaderOpen = false;
    }
  }
}
