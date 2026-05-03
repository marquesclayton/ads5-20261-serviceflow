import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:serviceflow/app/core/helpers/database_helper.dart';
import 'package:serviceflow/app/core/logging/log.service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_widget.dart';

void main() async {
  // 1. Garante a inicialização da comunicação com o sistema nativo
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inicializar Supabase PRIMEIRO (mais rápido)
    await initializeSupabase();

    // 3. Carregar o Banco de Dados local (inclui criação de tabelas)
    print('🔄 Inicializando banco de dados...');
    await DbHelper.instance.database;
    print('✅ Banco de dados inicializado');

    // 4. Inicializar sistema de logging centralizado (após DB pronto)
    print('🔄 Inicializando sistema de logs...');
    await LogService().initialize();

    // 5. ✅ EXECUTAR A APLICAÇÃO
    runApp(const AppEntry());
  } catch (e, stackTrace) {
    // Em caso de erro na inicialização, logar e tentar rodar mesmo assim
    print('❌ Erro na inicialização: $e');
    print('📋 Stack: $stackTrace');

    // Tentar rodar a aplicação mesmo com erro na inicialização
    runApp(const AppEntry());
  }
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
