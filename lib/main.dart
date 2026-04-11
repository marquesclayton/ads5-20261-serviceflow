import 'package:flutter/material.dart';

import 'app/app_widget.dart';

void main() {
  // 1. Garante a inicialização da comunicação com o sistema nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Exemplo: Aqui deve-se carregar o Banco de Dados ou as Configurações
  // await DatabaseHelper.instance.init();

  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidget();
  }
}
