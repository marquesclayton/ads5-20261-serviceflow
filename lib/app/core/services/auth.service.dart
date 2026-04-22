import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Retorna o usuário logado (ou null)
  User? get usuarioAtual => _supabase.auth.currentUser;

  // Stream que avisa o app sempre que o status do login mudar
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  Future<void> cadastrar(
      {required String email,
      required String senha,
      required String nome}) async {
    await _supabase.auth.signUp(
      email: email,
      password: senha,
      data: {
        'nome_completo': nome,
        'group_id': AppConfig.groupId,
      },
    );
  }

  Future<void> login(String email, String senha) async {
    await _supabase.auth.signInWithPassword(email: email, password: senha);
  }

  Future<void> logout() async => await _supabase.auth.signOut();
}
