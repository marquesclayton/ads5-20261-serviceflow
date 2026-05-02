import 'package:serviceflow/app/core/services/auth.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.validation.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.schedule.dart';

/// Exemplos de uso do módulo de Usuários seguindo arquitetura offline-first
///
/// 📚 ESTRUTURA DE CAMADAS IMPLEMENTADA:
///
/// Entidade (Entity) → Usuario.model.dart
/// ├─ Atributos: supabaseId, email, nomeCompleto, etc.
/// ├─ Mappers: toMap(), fromMap(), fromSupabase()
/// └─ Controle de Sync: isSync (0=pendente, 1=sincronizado)
///
/// Repository → Usuario.repository.dart
/// ├─ CRUD genérico herdado do BaseRepository
/// ├─ Métodos específicos: findByEmail(), findByGrupo()
/// └─ Sync control: markAsSynced(), findNotSynced()
///
/// Validation → Usuario.validation.dart
/// ├─ Campos obrigatórios e formatos
/// ├─ Regras de negócio: duplicidade, perfis válidos
/// └─ Validações específicas: login, configurações
///
/// Service → Usuario.service.dart
/// ├─ Orquestra: Validation → Repository
/// ├─ Fluxo de negócio: login(), updateConfiguracoes()
/// └─ Hooks: beforeCreate(), afterCreate()
///
/// Provider → Usuario.provider.dart
/// ├─ Comunicação exclusiva com Supabase
/// ├─ Serialização: _toSupabaseFormat(), _fromSupabaseFormat()
/// └─ Isolamento da API externa
///
/// Schedule → Usuario.schedule.dart
/// ├─ Background Worker: Timer.periodic()
/// ├─ Sincronização: SQLite ↔ Supabase
/// └─ Conflitos: resolução automática
///
/// 🚀 EXEMPLOS DE USO:

class ExemplosUsuarios {
  // === 1. INICIALIZAÇÃO DO SISTEMA ===

  static Future<void> inicializarSistema() async {
    print("🚀 Inicializando sistema de usuários...");

    // Configurar componentes do sistema (comentado para exemplo)
    // final repository = UsuarioRepository();
    // final validation = UsuarioValidation(repository);
    // final service = UsuarioService(validation, repository);

    // Iniciar agendador de sincronização
    final schedule = UsuarioSchedule();
    schedule.start();

    print("✅ Sistema inicializado com sucesso!");
  }

  // === 2. AUTENTICAÇÃO (via AuthService) ===

  static Future<void> exemploLogin() async {
    final authService = AuthService();

    try {
      // Login do usuário (Supabase + cache local)
      final usuario = await authService.login('joao@exemplo.com', 'senha123');

      print("✅ Login realizado: ${usuario.nomeCompleto}");
      print("   Email: ${usuario.email}");
      print("   Perfil: ${usuario.perfil}");
      print("   Último login: ${usuario.ultimoLogin}");
    } catch (e) {
      print("❌ Erro no login: $e");
    }
  }

  static Future<void> exemploLogout() async {
    final authService = AuthService();

    try {
      await authService.logout();
      print("✅ Logout realizado com sucesso");
    } catch (e) {
      print("❌ Erro no logout: $e");
    }
  }

  // === 3. OPERAÇÕES CRUD (via Service) ===

  static Future<void> exemploCriarUsuario() async {
    final repository = UsuarioRepository();
    final validation = UsuarioValidation(repository);
    final service = UsuarioService(validation, repository);

    try {
      final novoUsuario = Usuario(
        supabaseId: '550e8400-e29b-41d4-a716-446655440000', // UUID fictício
        email: 'maria@exemplo.com',
        nomeCompleto: 'Maria Silva Santos',
        grupoId: 'SF-GP-01',
        perfil: 'tecnico',
      );

      final usuarioSalvo = await service.create(novoUsuario);
      print("✅ Usuário criado com ID: ${usuarioSalvo.id}");
    } catch (e) {
      print("❌ Erro ao criar usuário: $e");
    }
  }

  static Future<void> exemploListarUsuarios() async {
    final repository = UsuarioRepository();
    final validation = UsuarioValidation(repository);
    final service = UsuarioService(validation, repository);

    try {
      final usuarios = await service.findAll();

      print("📋 Lista de usuários (${usuarios.length}):");
      for (final usuario in usuarios) {
        final syncStatus = usuario.isSync == 1 ? "✅" : "⏳";
        print("   $syncStatus ${usuario.nomeCompleto} (${usuario.email})");
      }
    } catch (e) {
      print("❌ Erro ao listar usuários: $e");
    }
  }

  // === 4. CONFIGURAÇÕES DO USUÁRIO ===

  static Future<void> exemploConfiguracoes() async {
    final authService = AuthService();

    try {
      // Atualizar configurações
      final usuario = await authService.updateUserSettings({
        'theme': 'dark',
        'notifications': true,
        'auto_sync': false,
        'language': 'pt-BR',
      });

      print("✅ Configurações atualizadas:");
      print("   Tema: ${usuario.configuracoesMap['theme']}");
      print("   Sincronizado: ${usuario.isSync == 1 ? 'Sim' : 'Pendente'}");
    } catch (e) {
      print("❌ Erro ao atualizar configurações: $e");
    }
  }

  // === 5. ADMINISTRAÇÃO (apenas admins) ===

  static Future<void> exemploAdministracao() async {
    final authService = AuthService();

    try {
      // Verificar se é admin
      final isAdmin = await authService.isAdmin();
      if (!isAdmin) {
        print("❌ Acesso negado: apenas administradores");
        return;
      }

      // Listar usuários do grupo
      final usuariosGrupo = await authService.getUsersByGrupo('SF-GP-01');
      print("👥 Usuários do grupo SF-GP-01: ${usuariosGrupo.length}");

      // Alterar perfil de usuário
      await authService.updateUserProfile(
          '550e8400-e29b-41d4-a716-446655440000', // Supabase ID
          'supervisor');
      print("✅ Perfil alterado para supervisor");

      // Obter estatísticas
      final stats = await authService.getUserStats();
      print("📊 Estatísticas:");
      print("   Total: ${stats['total_users']}");
      print("   Admins: ${stats['admins']}");
      print("   Técnicos: ${stats['tecnicos']}");
      print("   Online hoje: ${stats['online_hoje']}");
    } catch (e) {
      print("❌ Erro nas operações administrativas: $e");
    }
  }

  // === 6. SINCRONIZAÇÃO OFFLINE-FIRST ===

  static Future<void> exemploSincronizacao() async {
    final schedule = UsuarioSchedule();

    try {
      // Verificar status do agendador
      print("⚡ Status do agendador: Ativo");

      // Obter estatísticas básicas
      print("📊 Sincronização:");
      print("   Funcionalidade: ${schedule.featureName}");
      print("   Intervalo: ${schedule.syncInterval.inMinutes} min");

      // Forçar sincronização imediata
      final resultado = await schedule.syncNow();
      print("🔄 Resultado da sincronização: ${resultado ? 'Sucesso' : 'Erro'}");
    } catch (e) {
      print("❌ Erro na sincronização: $e");
    }
  }

  // === 7. CENÁRIOS OFFLINE ===

  static Future<void> exemploUsoOffline() async {
    print("📱 Demonstrando uso offline...");

    final repository = UsuarioRepository();

    try {
      // Mesmo sem internet, dados locais funcionam
      final usuariosLocais = await repository.findAll();
      print("💾 Usuários no cache local: ${usuariosLocais.length}");

      // Buscar por email (funciona offline)
      final usuario = await repository.findByEmail('joao@exemplo.com');
      if (usuario != null) {
        print("👤 Usuário encontrado offline: ${usuario.nomeCompleto}");
        print("   Último login: ${usuario.ultimoLogin}");
        print(
            "   Status sync: ${usuario.isSync == 1 ? 'Sincronizado' : 'Pendente'}");
      }

      // Listar pendências de sincronização
      final pendentes = await repository.findNotSynced();
      print("⏳ Aguardando sincronização: ${pendentes.length} usuários");
    } catch (e) {
      print("❌ Erro no uso offline: $e");
    }
  }

  // === 8. SETUP INICIAL DO SISTEMA ===

  static Future<void> exemploSetupInicial() async {
    final authService = AuthService();

    try {
      // Verificar se é primeiro acesso
      final isPrimeiro = await authService.isFirstAccess();

      if (isPrimeiro) {
        print("🎯 Primeiro acesso - criando admin inicial...");

        final admin = await authService.createInitialAdmin(
            'admin@serviceflow.com', 'admin123456', 'Administrador Sistema');

        print("✅ Admin inicial criado: ${admin.email}");
      } else {
        print("ℹ️ Sistema já inicializado");
      }
    } catch (e) {
      print("❌ Erro no setup: $e");
    }
  }

  // === 9. MONITORAMENTO E DEBUG ===

  static Future<void> exemploMonitoramento() async {
    final repository = UsuarioRepository();
    final schedule = UsuarioSchedule();

    print("🔍 Status do sistema:");

    try {
      // Estatísticas do repositório
      final todos = await repository.findAll();
      final pendentes = await repository.findNotSynced();
      final admins = await repository.findByPerfil('admin');

      print("📊 Banco local:");
      print("   Total: ${todos.length}");
      print("   Pendentes: ${pendentes.length}");
      print("   Admins: ${admins.length}");

      // Status do agendador
      print("⚡ Agendador:");
      print("   Funcionalidade: ${schedule.featureName}");
      print("   Intervalo: ${schedule.syncInterval.inMinutes} min");
    } catch (e) {
      print("❌ Erro no monitoramento: $e");
    }
  }
}

/// 🎯 COMO USAR NA SUA APLICAÇÃO:
///
/// 1. No main.dart:
///    ```dart
///    await ExemplosUsuarios.inicializarSistema();
///    ```
///
/// 2. Na tela de login:
///    ```dart
///    await ExemplosUsuarios.exemploLogin();
///    ```
///
/// 3. Na tela de configurações:
///    ```dart
///    await ExemplosUsuarios.exemploConfiguracoes();
///    ```
///
/// 4. Para administração:
///    ```dart
///    await ExemplosUsuarios.exemploAdministracao();
///    ```
///
/// 5. Para monitorar sync:
///    ```dart
///    await ExemplosUsuarios.exemploSincronizacao();
///    ```

void main() {
  print("📚 Arquivo de exemplos - não executar diretamente");
  print("   Consulte os métodos da classe ExemplosUsuarios");
}
