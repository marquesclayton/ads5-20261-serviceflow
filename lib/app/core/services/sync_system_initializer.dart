// Exemplo de como inicializar o sistema de sincronização
// Adicionar ao main.dart ou criar um arquivo de inicialização separado

import 'package:serviceflow/app/core/services/schedule_manager.dart';
import 'package:serviceflow/app/modules/clientes/cliente.schedule.dart';

/// Inicializador do sistema de sincronização
class SyncSystemInitializer {
  /// Inicializar todo o sistema de sincronização
  static Future<void> initialize() async {
    print('🔄 Inicializando sistema de sincronização...');

    try {
      // 1. Obter instância do ScheduleManager
      final scheduleManager = ScheduleManager();

      // 2. Registrar schedules adicionais (além dos auto-registrados)
      scheduleManager.registerSchedule(ClienteSchedule());
      // scheduleManager.registerSchedule(OrdemServicoSchedule());
      // scheduleManager.registerSchedule(RelatoriosSchedule());

      // 3. Inicializar todos os schedules
      await scheduleManager.initialize();

      // 4. Log do status
      final status = scheduleManager.getStatus();
      print('✅ Sistema de sincronização inicializado:');
      print('   - Features: ${status['schedules_count']}');
      print(
          '   - Registradas: ${scheduleManager.getRegisteredFeatures().join(', ')}');
    } catch (e) {
      print('❌ Erro ao inicializar sistema de sincronização: $e');
    }
  }

  /// Parar sistema de sincronização (chamar no dispose do app)
  static Future<void> dispose() async {
    print('🛑 Parando sistema de sincronização...');
    final scheduleManager = ScheduleManager();
    await scheduleManager.stopAll();
    print('✅ Sistema de sincronização parado');
  }

  /// Forçar sincronização completa (útil para botão manual)
  static Future<Map<String, bool>> forceSyncAll() async {
    print('🔄 Forçando sincronização completa...');
    final scheduleManager = ScheduleManager();
    final results = await scheduleManager.syncAll();

    final successCount = results.values.where((success) => success).length;
    print('✅ Sincronização completa: $successCount/${results.length} sucessos');

    return results;
  }

  /// Sincronizar feature específica
  static Future<bool> syncFeature(String featureName) async {
    print('🔄 Sincronizando feature: $featureName');
    final scheduleManager = ScheduleManager();
    final success = await scheduleManager.syncFeature(featureName);

    print(
        '${success ? '✅' : '❌'} Sync $featureName: ${success ? 'SUCCESS' : 'FAILED'}');
    return success;
  }
}

/* 
=== COMO USAR NO main.dart ===

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar sistema de sincronização
  await SyncSystemInitializer.initialize();
  
  runApp(ServiceFlowApp());
}

class ServiceFlowApp extends StatefulWidget {
  @override
  _ServiceFlowAppState createState() => _ServiceFlowAppState();
}

class _ServiceFlowAppState extends State<ServiceFlowApp> {
  @override
  void dispose() {
    // Parar schedules ao fechar app
    SyncSystemInitializer.dispose();
    super.dispose();
  }

  // ... resto do app
}

=== COMO USAR EM PÁGINAS ===

// Botão de sincronização manual
ElevatedButton(
  onPressed: () async {
    final results = await SyncSystemInitializer.forceSyncAll();
    // Mostrar resultado para usuário
  },
  child: Text('Sincronizar Tudo'),
)

// Sincronizar feature específica
ElevatedButton(
  onPressed: () async {
    final success = await SyncSystemInitializer.syncFeature('clientes');
    // Mostrar resultado
  },
  child: Text('Sincronizar Clientes'),
)

*/
