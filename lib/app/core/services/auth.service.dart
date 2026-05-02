import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.validation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de Autenticação seguindo arquitetura offline-first
/// Responsável pela orquestração entre Supabase Auth e cache local
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Serviços da arquitetura em camadas
  late final UsuarioService _usuarioService;
  
  // Singleton
  static final AuthService _instance = AuthService._init();
  factory AuthService() => _instance;
  
  AuthService._init() {
    final repository = UsuarioRepository();
    final validation = UsuarioValidation(repository);
    _usuarioService = UsuarioService(validation, repository);
  }

  // === PROPRIEDADES PÚBLICAS ===

  /// Retorna o usuário logado do Supabase (ou null)
  User? get usuarioSupabase => _supabase.auth.currentUser;

  /// Stream que avisa quando o status do login mudar
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  // === MÉTODOS DE AUTENTICAÇÃO ===

  /// Fazer login (Supabase + cache local)
  Future<Usuario> login(String email, String senha) async {
    return await _usuarioService.login(email, senha);
  }

  /// Cadastrar novo usuário
  Future<void> cadastrar({
    required String email,
    required String senha,
    required String nomeCompleto,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: senha,
      data: {
        'nome_completo': nomeCompleto,
        'group_id': AppConfig.groupId,
        'perfil': 'tecnico', // Padrão para novos usuários
      },
    );
  }

  /// Fazer logout (Supabase + limpar contexto)
  Future<void> logout() async {
    await _usuarioService.logout();
  }

  // === MÉTODOS DE SESSÃO ===

  /// Verifica se há sessão válida (Supabase + cache local)
  Future<bool> hasValidSession() async {
    final usuario = await getUsuarioAtual();
    return usuario != null;
  }

  /// Recupera dados do usuário atual (offline-first)
  Future<Usuario?> getUsuarioAtual() async {
    return await _usuarioService.getUsuarioAtual();
  }

  /// Recupera dados básicos do cache local (funciona offline)
  Future<Map<String, dynamic>?> getUserDataCache() async {
    final usuario = await _usuarioService.getUsuarioAtual();
    return usuario?.toMap();
  }

  // === MÉTODOS DE CONFIGURAÇÃO ===

  /// Atualizar configurações do usuário
  Future<Usuario> updateUserSettings(Map<String, dynamic> settings) async {
    final usuario = await getUsuarioAtual();
    if (usuario == null) {
      throw Exception("Usuário não está logado");
    }
    
    return await _usuarioService.updateConfiguracoes(usuario, settings);
  }

  // === MÉTODOS ADMINISTRATIVOS ===

  /// Verificar se usuário atual é admin
  Future<bool> isAdmin() async {
    final usuario = await getUsuarioAtual();
    return usuario?.isAdmin ?? false;
  }

  /// Buscar usuários por grupo (apenas para admins)
  Future<List<Usuario>> getUsersByGrupo(String grupoId) async {
    final usuario = await getUsuarioAtual();
    if (usuario == null || !usuario.isAdmin) {
      throw Exception("Acesso negado: apenas administradores");
    }
    
    return await _usuarioService.findByGrupo(grupoId);
  }

  /// Alterar perfil de usuário (apenas para admins)
  Future<Usuario> updateUserProfile(String supabaseIdAlvo, String novoPerfil) async {
    final usuarioLogado = await getUsuarioAtual();
    if (usuarioLogado == null) {
      throw Exception("Usuário não está logado");
    }
    
    return await _usuarioService.updatePerfil(usuarioLogado, supabaseIdAlvo, novoPerfil);
  }

  // === MÉTODOS DE SINCRONIZAÇÃO ===

  /// Sincronizar dados pendentes (background task)
  Future<void> syncPendingData() async {
    try {
      await _usuarioService.syncPendingUsers();
      print("✅ Sincronização de usuários concluída");
    } catch (e) {
      print("❌ Erro na sincronização: $e");
    }
  }

  // === MÉTODOS UTILITÁRIOS ===

  /// Verificar se é o primeiro acesso ao sistema
  Future<bool> isFirstAccess() async {
    return await _usuarioService.isPrimeiroAcesso();
  }

  /// Criar admin inicial (setup do sistema)
  Future<Usuario> createInitialAdmin(String email, String senha, String nomeCompleto) async {
    return await _usuarioService.criarAdminInicial(email, senha, nomeCompleto);
  }

  /// Obter estatísticas dos usuários
  Future<Map<String, int>> getUserStats() async {
    return await _usuarioService.getEstatisticas();
  }

  /// Forçar refresh do token (se necessário)
  Future<void> refreshSession() async {
    await _supabase.auth.refreshSession();
  }

  // === MÉTODOS DE VALIDAÇÃO ===

  /// Validar dados de login antes de tentar autenticar
  Future<void> validateLoginData(String email, String senha) async {
    final validation = UsuarioValidation(UsuarioRepository());
    await validation.validateLogin(email, senha);
  }
}
