import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_widget.dart';

void main() async {
  // 1. Garante a inicialização da comunicação com o sistema nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Exemplo: Aqui deve-se carregar o Banco de Dados ou as Configurações
  // await DatabaseHelper.instance.init();
  initializeSupabase();

  runApp(const AppEntry());
}

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseKey,
  );
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidget();
  }
}
