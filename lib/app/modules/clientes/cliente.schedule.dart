import 'package:serviceflow/app/core/base/base.schedule.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'client.repository.dart';
import 'cliente.provider.dart';

/// Schedule específico para sincronização de clientes
/// Exemplo de implementação seguindo BaseSchedule
class ClienteSchedule extends BaseSchedule<Cliente, ClienteProvider> {
  // Singleton para consistência
  static final ClienteSchedule _instance = ClienteSchedule._init();
  factory ClienteSchedule() => _instance;

  ClienteSchedule._init() : super(ClienteRepository(), ClienteProvider());

  @override
  String get featureName => 'clientes';

  /// Configuração para clientes - intervalo padrão
  @override
  Duration get syncInterval => const Duration(minutes: 5);

  /// Métodos específicos para clientes

  /// Sincronizar clientes por status (ativos/inativos)
  Future<bool> syncByStatus(bool activeOnly) async {
    try {
      final clientes = await repository.findAll();
      final filteredClientes =
          activeOnly ? clientes.where((c) => c.ativo).toList() : clientes;

      final pendingClientes = clientes.where((c) => c.isSync == 0).toList();

      if (pendingClientes.isEmpty) {
        return true;
      }

      int successCount = 0;
      for (final cliente in pendingClientes) {
        if (await provider.syncToCloud(cliente)) {
          cliente.isSync = 1;
          await repository.update(cliente);
          successCount++;
        }
      }

      print(
          'Sync por status: $successCount/${pendingClientes.length} sincronizados');
      return successCount == pendingClientes.length;
    } catch (e) {
      print('Erro no sync por status: $e');
      return false;
    }
  }

  /// Sincronizar apenas clientes de uma cidade específica
  Future<bool> syncByCity(String cidade) async {
    try {
      final allClientes = await repository.findAll();
      final clientes = allClientes.where((c) => c.cidade == cidade).toList();
      final pendingClientes = clientes.where((c) => c.isSync == 0).toList();

      if (pendingClientes.isEmpty) {
        return true;
      }

      int successCount = 0;
      for (final cliente in pendingClientes) {
        if (await provider.syncToCloud(cliente)) {
          cliente.isSync = 1;
          await repository.update(cliente);
          successCount++;
        }
      }

      print(
          'Sync cidade $cidade: $successCount/${pendingClientes.length} sincronizados');
      return successCount == pendingClientes.length;
    } catch (e) {
      print('Erro no sync por cidade: $e');
      return false;
    }
  }
}
