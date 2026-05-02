/// ⚠️ ARQUIVO OBSOLETO ⚠️
///
/// Este arquivo foi substituído pela nova arquitetura em camadas.
///
/// 📚 CONSULTE OS NOVOS ARQUIVOS:
/// - lib/app/modules/usuarios/EXEMPLOS_USO_USUARIOS.dart
/// - lib/app/core/services/auth.service.dart (refatorado)
///
/// 🏗️ NOVA ARQUITETURA IMPLEMENTADA:
/// Entity → Repository → Validation → Service → Controller
/// Provider (Supabase) + Schedule (Background Sync)
///
/// 🚀 COMO USAR AGORA:
/// ```dart
/// // Login
/// final usuario = await AuthService().login(email, senha);
///
/// // Verificar sessão
/// final hasSession = await AuthService().hasValidSession();
///
/// // Configurações
/// await AuthService().updateUserSettings({...});
///
/// // Logout
/// await AuthService().logout();
/// ```

void main() {
  print("📚 Arquivo obsoleto - usar nova arquitetura em /usuarios/");
}
