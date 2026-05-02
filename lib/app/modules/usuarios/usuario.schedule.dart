import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serviceflow/app/core/base/base.schedule.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.provider.dart';

/// Schedule específico para sincronização de usuários
///
/// Responsável por:
/// - Coordenar sincronização entre UsuarioRepository e UsuarioProvider
/// - Configurações específicas de timing e frequência
/// - Lógicas especiais de usuários (cache de login, etc.)
class UsuarioSchedule
    extends BaseSchedule<Usuario, UsuarioRepository, UsuarioProvider> {
  // Singleton para manter compatibilidade com código existente
  static final UsuarioSchedule _instance = UsuarioSchedule._init();
  factory UsuarioSchedule() => _instance;

  UsuarioSchedule._init() : super(UsuarioRepository(), UsuarioProvider());

  @override
  String get featureName => 'usuarios';

  /// Configuração específica para usuários - mais frequente devido ao login
  @override
  Duration get syncInterval => const Duration(minutes: 3);

  /// Métodos específicos para usuários

  /// Sincronizar dados do usuário logado prioritariamente
  Future<bool> syncCurrentUser(String email) async {
    try {
      final currentUser = await repository.findByEmail(email);
      if (currentUser != null && currentUser.isSync == 0) {
        return await provider.syncToCloud(currentUser);
      }
      return true;
    } catch (e) {
      print('Erro ao sincronizar usuário atual: $e');
      return false;
    }
  }

  /// Limpar cache de usuários inativos
  Future<void> cleanupInactiveUsers() async {
    try {
      // Por enquanto, apenas log - implementação futura
      print('Cleanup de usuários inativos seria executado aqui');
    } catch (e) {
      print('Erro no cleanup de usuários: $e');
    }
  }

  /// Sincronização customizada com prioridades
  @override
  Future<bool> syncNow() async {
    // 1. Primeiro sincronizar usuário atual (se houver)
    final currentUserEmail = await _getCurrentUserEmail();
    if (currentUserEmail != null) {
      await syncCurrentUser(currentUserEmail);
    }

    // 2. Executar sincronização padrão
    final success = await super.syncNow();

    // 3. Cleanup periódico (a cada 24h)
    if (await _shouldRunCleanup()) {
      await cleanupInactiveUsers();
    }

    return success;
  }

  /// Helper para obter email do usuário logado
  Future<String?> _getCurrentUserEmail() async {
    try {
      const storage = FlutterSecureStorage();
      return await storage.read(key: 'current_user_email');
    } catch (e) {
      return null;
    }
  }

  /// Helper para verificar se deve executar cleanup
  Future<bool> _shouldRunCleanup() async {
    try {
      const storage = FlutterSecureStorage();
      final lastCleanupStr = await storage.read(key: 'usuarios_last_cleanup');

      if (lastCleanupStr == null) {
        await storage.write(
            key: 'usuarios_last_cleanup',
            value: DateTime.now().toIso8601String());
        return true;
      }

      final lastCleanup = DateTime.parse(lastCleanupStr);
      final shouldRun = DateTime.now().difference(lastCleanup).inHours >= 24;

      if (shouldRun) {
        await storage.write(
            key: 'usuarios_last_cleanup',
            value: DateTime.now().toIso8601String());
      }

      return shouldRun;
    } catch (e) {
      return false;
    }
  }
}
