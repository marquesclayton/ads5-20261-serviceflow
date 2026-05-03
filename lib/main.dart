import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:serviceflow/app/core/helpers/database_helper.dart';
import 'package:serviceflow/app/core/logging/log.service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_widget.dart';

void main() async {
  // 1. Garante a inicialização da comunicação com o sistema nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Exemplo: Aqui deve-se carregar o Banco de Dados ou as Configurações
  await DbHelper.instance.database;

  // 3. Inicializar sistema de logging centralizado
  await LogService().initialize();

  // 4. Inicializar Supabase ANTES do app rodar
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
