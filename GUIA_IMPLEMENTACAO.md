# 🏗️ Guia Completo de Implementação - Arquitetura ServiceFlow

## 📋 Visão Geral
Este guia apresenta a implementação completa da arquitetura **ServiceFlow**, focando na integração entre **BaseProvider + BaseSchedule** e o sistema de **Mixins Centralizados** para operações UI.

## 🎯 Objetivos do Guia
1. **Arquitetura Base**: Como implementar BaseModel → BaseRepository → BaseService → BaseController
2. **Sistema de Mixins**: LoaderMixin + MessagesMixin integrados ao BaseController
3. **Operações Centralizadas**: executeOperation, executeListOperation, executeCrudOperation
4. **Sistema de Sincronização**: BaseProvider + BaseSchedule + ScheduleManager
5. **Exception Convergence**: Todas exceções convergem para mensagens amigáveis

---

## 🏗️ PARTE 1: Implementação da Arquitetura Base

### 1.1 BaseModel - Entidade Base
```dart
// 📄 lib/app/core/base/base.model.dart
abstract class BaseModel {
  int? id;
  int isSync; // 0 = pendente, 1 = sincronizado
  DateTime? createdAt;
  
  BaseModel({
    this.id,
    this.isSync = 0,
    this.createdAt,
  });
  
  // Métodos abstratos que devem ser implementados
  Map<String, dynamic> toMap();
  String toJson() => json.encode(toMap());
  BaseModel copyWith();
  
  // Métodos de controle de sincronização
  bool get isPendingSync => isSync == 0;
  bool get isSynchronized => isSync == 1;
  void markAsSynced() => isSync = 1;
  void markAsPending() => isSync = 0;
}
```

### 1.2 BaseRepository - Persistência SQLite
```dart
// 📄 lib/app/core/base/base.repository.dart
abstract class BaseRepository<E extends BaseModel> {
  final DbHelper _dbHelper = DbHelper.instance;
  
  String get tableName; // Implementar em cada repository
  
  // Operações CRUD base
  Future<int> insert(E item);
  Future<int> update(E item);
  Future<int> delete(int id);
  Future<List<E>> findAll();
  Future<E?> findById(int id);
  
  // Operações específicas para sync
  Future<List<E>> findAllPendingSync() async {
    final db = await _dbHelper.getConnection();
    final maps = await db.query(
      tableName, 
      where: 'is_sync = ? AND ativo = ?',
      whereArgs: [0, 1],
    );
    return maps.map((map) => fromMap(map)).toList();
  }
  
  // Método abstrato para conversão
  E fromMap(Map<String, dynamic> map);
}
```

### 1.3 BaseService - Orquestração Business
```dart
// 📄 lib/app/core/base/base.service.dart
abstract class BaseService<E extends BaseModel, R extends BaseRepository<E>, V extends BaseValidation<E, R>> {
  final R repository;
  final V validation;
  
  BaseService({required this.repository, required this.validation});
  
  Future<E> create(E entity) async {
    await validation.validateFieldCreate(entity);
    await validation.validateRulesCreate(entity);
    
    final id = await repository.insert(entity);
    return cloneModelWithId(entity, id);
  }
  
  Future<E> update(E entity) async {
    await validation.validateFieldUpdate(entity);
    await validation.validateRulesUpdate(entity);
    
    await repository.update(entity);
    return entity;
  }
  
  Future<void> delete(int id) async {
    await repository.delete(id);
  }
  
  Future<List<E>> listar() async {
    return await repository.findAll();
  }
  
  // Método abstrato para clonagem com ID
  E cloneModelWithId(E model, int id);
}
```

---

## 🎭 PARTE 2: Sistema de Mixins Centralizados

### 2.1 LoaderMixin - Controle Automático de Loading
```dart
// 📄 lib/app/core/mixins/loader.mixin.dart
mixin LoaderMixin {
  void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
              child: Text(message ?? 'Carregando...'),
            ),
          ],
        ),
      ),
    );
  }
  
  void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
```

### 2.2 MessagesMixin - Sistema de Mensagens com Durações
```dart
// 📄 lib/app/core/mixins/messages.mixin.dart
mixin MessagesMixin {
  // ✅ Sucesso: Auto-remove após 3 segundos
  void showSuccess(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3), // 3 segundos
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // ❌ Erro: Não remove automaticamente
  void showError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(days: 365), // Não remove automaticamente
      action: SnackBarAction(
        label: 'Fechar',
        textColor: Colors.white,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // ⚠️ Aviso: Auto-remove após 4 segundos
  void showWarning(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.warning, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 4), // 4 segundos
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // 🔔 Confirmação: Aguarda ação do usuário
  Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[Icon(icon), SizedBox(width: 8)],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null 
                ? TextButton.styleFrom(foregroundColor: confirmColor) 
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
```

### 2.3 BaseController - Widget com Mixins Integrados e Generics Type-Safe
```dart
// 📄 lib/app/core/base/base.controller.dart
abstract class BaseController<E extends BaseModel, R extends BaseRepository<E>,
        V extends BaseValidation<E, R>, S extends BaseService<E, R, V>>
    extends StatelessWidget with LoaderMixin, MessagesMixin {
  
  final S service;
  final E? model;
  
  BaseController(this.service, {this.model});
  
  // Método abstrato que deve ser implementado pelas pages
  Widget buildPage(BuildContext context, S service);
  
  @override
  Widget build(BuildContext context) {
    return buildPage(context, service);
  }
  
  // 📋 OPERAÇÃO GENÉRICA
  Future<T?> executeOperation<T>(
    BuildContext context,
    Future<T> operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showSuccessMessage = false,
  }) async {
    try {
      showLoading(context, message: loadingMessage);
      
      final result = await operation;
      
      hideLoading(context);
      
      if (showSuccessMessage && successMessage != null) {
        showSuccess(context, successMessage);
      }
      
      return result;
      
    } catch (e) {
      hideLoading(context);
      _handleException(context, e, errorMessage);
      return null;
    }
  }
  
  // 📋 OPERAÇÃO DE LISTA
  Future<List<T>> executeListOperation<T>(
    BuildContext context,
    Future<List<T>> operation, {
    String? loadingMessage,
    String? errorMessage,
  }) async {
    try {
      showLoading(context, message: loadingMessage);
      
      final result = await operation;
      
      hideLoading(context);
      
      return result;
      
    } catch (e) {
      hideLoading(context);
      _handleException(context, e, errorMessage);
      return [];
    }
  }
  
  // 📋 OPERAÇÃO CRUD COM CONFIRMAÇÃO
  Future<bool> executeCrudOperation(
    BuildContext context,
    Future operation, {
    String? confirmTitle,
    String? confirmMessage,
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool requiresConfirmation = false,
  }) async {
    try {
      // Confirmação se necessária
      if (requiresConfirmation) {
        final confirmed = await showConfirmation(
          context,
          title: confirmTitle ?? 'Confirmar',
          message: confirmMessage ?? 'Tem certeza?',
        );
        
        if (confirmed != true) return false;
      }
      
      showLoading(context, message: loadingMessage);
      
      await operation;
      
      hideLoading(context);
      
      if (successMessage != null) {
        showSuccess(context, successMessage);
      }
      
      return true;
      
    } catch (e) {
      hideLoading(context);
      _handleException(context, e, errorMessage);
      return false;
    }
  }
  
  // 🛡️ TRATAMENTO CENTRALIZADO DE EXCEÇÕES
  void _handleException(BuildContext context, dynamic exception, String? errorMessage) {
    String userMessage;
    
    if (exception.toString().contains('FOREIGN KEY') || 
        exception.toString().contains('UNIQUE constraint')) {
      userMessage = 'Erro de integridade de dados. Verifique as informações.';
    } else if (exception.toString().contains('SocketException') || 
               exception.toString().contains('TimeoutException')) {
      userMessage = 'Erro de conexão. Verifique sua internet.';
    } else if (exception.runtimeType.toString().contains('Validation')) {
      userMessage = exception.toString();
    } else {
      userMessage = errorMessage ?? 'Erro inesperado. Tente novamente.';
    }
    
    showError(context, userMessage);
    
    // Log técnico para debug (não mostrar ao usuário)
    debugPrint('🔴 EXCEPTION: $exception');
  }
}
```

---

## 🔄 PARTE 3: Sistema de Sincronização

### 3.1 BaseProvider - Comunicação Externa
```dart
// 📄 lib/app/core/base/base.provider.dart
abstract class BaseProvider<E extends BaseModel> {
  final AppClient client = AppClient.instance;
  final LogService logger = LogService.instance;
  
  String get endpoint; // Ex: '/usuarios'
  
  // Métodos abstratos para conversão
  Map<String, dynamic> toExternalFormat(E entity);
  E fromExternalFormat(Map<String, dynamic> data);
  
  Future<void> syncToCloud(E entity) async {
    try {
      final data = toExternalFormat(entity);
      
      if (entity.id != null) {
        await client.put('$endpoint/${entity.id}', data);
      } else {
        await client.post(endpoint, data);
      }
      
      logger.info('BaseProvider', 'syncToCloud', 'Entidade sincronizada com sucesso');
      
    } catch (e) {
      logger.error('BaseProvider', 'syncToCloud', 'Erro ao sincronizar: $e');
      throw e;
    }
  }
  
  Future<List<E>> fetchFromCloud() async {
    try {
      final response = await client.get(endpoint);
      final List<dynamic> data = response.data;
      
      return data.map((item) => fromExternalFormat(item)).toList();
      
    } catch (e) {
      logger.error('BaseProvider', 'fetchFromCloud', 'Erro ao buscar dados: $e');
      throw e;
    }
  }
}
```

### 3.2 BaseSchedule - Sincronização Automática
```dart
// 📄 lib/app/core/base/base.schedule.dart
abstract class BaseSchedule<E extends BaseModel, R extends BaseRepository<E>, P extends BaseProvider<E>> {
  final R repository;
  final P provider;
  final String featureName;
  final Duration syncInterval;
  
  Timer? _syncTimer;
  bool _isRunning = false;
  
  BaseSchedule({
    required this.repository,
    required this.provider,
    required this.featureName,
    this.syncInterval = const Duration(minutes: 5),
  });
  
  Future<void> start() async {
    if (_isRunning) return;
    
    _isRunning = true;
    _syncTimer = Timer.periodic(syncInterval, (_) => syncNow());
    
    print('🔄 $featureName Schedule iniciado (${syncInterval.inMinutes}min)');
  }
  
  void stop() {
    _syncTimer?.cancel();
    _isRunning = false;
    print('⏹️ $featureName Schedule parado');
  }
  
  Future<void> syncNow() async {
    try {
      await uploadPendingChanges();
      await downloadUpdates();
      
      print('✅ $featureName sincronizado com sucesso');
      
    } catch (e) {
      print('❌ Erro na sincronização $featureName: $e');
    }
  }
  
  Future<void> uploadPendingChanges() async {
    final pendingItems = await repository.findAllPendingSync();
    
    for (final item in pendingItems) {
      try {
        await provider.syncToCloud(item);
        item.markAsSynced();
        await repository.update(item);
      } catch (e) {
        print('❌ Erro ao enviar ${item.id}: $e');
      }
    }
  }
  
  Future<void> downloadUpdates() async {
    try {
      final cloudItems = await provider.fetchFromCloud();
      
      for (final item in cloudItems) {
        final existing = await repository.findById(item.id!);
        
        if (existing == null) {
          item.markAsSynced();
          await repository.insert(item);
        } else {
          // Lógica de resolução de conflito
          final resolved = await resolveConflict(existing, item);
          await repository.update(resolved);
        }
      }
    } catch (e) {
      print('❌ Erro ao baixar atualizações: $e');
    }
  }
  
  // Método abstrato para resolução de conflitos
  Future<E> resolveConflict(E local, E remote);
}
```

### 3.3 ScheduleManager - Coordenador Central
```dart
// 📄 lib/app/core/services/schedule.manager.dart
class ScheduleManager {
  static final ScheduleManager _instance = ScheduleManager._internal();
  static ScheduleManager get instance => _instance;
  ScheduleManager._internal();
  
  final List<BaseSchedule> _schedules = [];
  
  Future<void> initialize() async {
    // Registrar todos os schedules da aplicação
    _schedules.addAll([
      UsuarioSchedule(
        repository: UsuarioRepository(),
        provider: UsuarioProvider(),
        featureName: 'Usuários',
      ),
      // Adicionar outros schedules aqui...
    ]);
    
    // Iniciar todos
    for (final schedule in _schedules) {
      await schedule.start();
    }
    
    print('🚀 ScheduleManager inicializado com ${_schedules.length} schedules');
  }
  
  Future<void> stopAll() async {
    for (final schedule in _schedules) {
      schedule.stop();
    }
    print('⏹️ Todos os schedules foram parados');
  }
  
  Future<void> syncAll() async {
    for (final schedule in _schedules) {
      await schedule.syncNow();
    }
  }
}
```

---

## 🚀 PARTE 4: Implementação Prática

### 4.1 Exemplo: UsuariosListPage Completa com Generics Type-Safe
```dart
// 📄 lib/app/modules/usuarios/presentation/pages/usuarios_list_page.dart
class UsuariosListPage extends BaseController<Usuario, UsuarioRepository, 
        UsuarioValidation, UsuarioService> {
  
  UsuariosListPage(UsuarioService service) : super(service);
  
  @override
  Widget buildPage(BuildContext context, UsuarioService service) {
    return _UsuariosListPageState();
  }
}

class _UsuariosListPageState extends State<UsuariosListPage> {
  List<Usuario> _usuarios = [];
  
  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }
  
  Future<void> _carregarUsuarios() async {
    final usuarios = await widget.executeListOperation<Usuario>(
      context,
      widget.service.listar(),
      loadingMessage: 'Carregando usuários...',
      errorMessage: 'Erro ao carregar lista de usuários',
    );
    
    setState(() {
      _usuarios = usuarios;
    });
  }
  
  Future<void> _excluirUsuario(Usuario usuario) async {
    final sucesso = await widget.executeCrudOperation(
      context,
      widget.service.delete(usuario.id!),
      confirmTitle: 'Confirmar Exclusão',
      confirmMessage: 'Tem certeza que deseja excluir ${usuario.nomeCompleto}?',
      loadingMessage: 'Excluindo usuário...',
      successMessage: 'Usuário excluído com sucesso',
      requiresConfirmation: true,
    );
    
    if (sucesso) {
      _carregarUsuarios();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuários')),
      body: ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return ListTile(
            title: Text(usuario.nomeCompleto),
            subtitle: Text(usuario.email),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Excluir'),
                  onTap: () => _excluirUsuario(usuario),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## ✅ PARTE 5: Checklist de Implementação

### 📋 BaseModel + BaseRepository
- [ ] Criar entidade herdando de BaseModel
- [ ] Implementar toMap(), fromMap(), copyWith()
- [ ] Criar repository herdando de BaseRepository
- [ ] Implementar tableName e métodos CRUD
- [ ] Testar operações de banco localmente

### 📋 BaseService + BaseValidation
- [ ] Criar validation com regras de negócio
- [ ] Criar service orquestrando repository + validation
- [ ] Implementar cloneModelWithId()
- [ ] Testar fluxo create/update/delete

### 📋 BaseController + Mixins
- [ ] Page herdando de BaseController
- [ ] Usar executeListOperation() para listar
- [ ] Usar executeCrudOperation() para CRUD
- [ ] Usar executeOperation() para casos especiais
- [ ] Testar fluxo completo loader→service→mensagem

### 📋 BaseProvider + BaseSchedule
- [ ] Criar provider herdando de BaseProvider
- [ ] Implementar toExternalFormat() e fromExternalFormat()
- [ ] Criar schedule herdando de BaseSchedule
- [ ] Implementar resolveConflict()
- [ ] Registrar no ScheduleManager
- [ ] Testar sincronização automática

### 📋 Integração Final
- [ ] Inicializar ScheduleManager no main.dart
- [ ] Testar fluxo offline-first
- [ ] Validar tratamento de exceções
- [ ] Confirmar durações das mensagens
- [ ] Testar comportamento sem internet

---

## 🎯 Resultados Esperados

### ✅ Para o Desenvolvedor:
- **80% menos código** nas pages
- **Zero boilerplate** de loading/error
- **Tratamento automático** de exceções
- **UX consistente** em toda aplicação
- **Manutenibilidade máxima**

### ✅ Para o Usuário:
- **Loading visual** em todas operações
- **Mensagens claras** de sucesso/erro
- **Confirmações** para ações destrutivas
- **Funcionamento offline** com sincronização
- **Interface responsiva** e profissional

### ✅ Para o Sistema:
- **Arquitetura escalável** e modular
- **Logs centralizados** para debugging
- **Sincronização automática** em background
- **Tratamento robusto** de conflitos
- **Performance otimizada**

---

## 🔗 Documentação Adicional

- **README.md**: Visão geral da arquitetura
- **EXEMPLOS_USO_USUARIOS.dart**: Códigos práticos de implementação
- **Código-fonte**: Navegue pelos modules/clientes para ver exemplo funcionando
- **Logs**: Use flutter logs para acompanhar sincronização

**🎉 Com esta arquitetura, você terá um sistema profissional, escalável e de fácil manutenção!**

## 📋 Visão Geral da Arquitetura

A arquitetura ServiceFlow implementa um padrão **offline-first** com sincronização automática através de camadas base abstratas:

```
BaseModel → BaseRepository → BaseProvider → BaseSchedule
    ↓             ↓              ↓             ↓
 Entidade    SQLite Local   API Externa   Background Sync
```

## 🔧 Implementando Nova Feature

### Passo 1: Criar o Model
```dart
// lib/app/modules/[feature]/[feature].model.dart
class MinhaFeature extends BaseModel {
  final String nome;
  final String descricao;
  
  MinhaFeature({
    super.id,
    required this.nome,
    required this.descricao,
    super.isSync = 0,
    super.createdAt,
  });

  @override
  MinhaFeature fromMap(Map<String, dynamic> map) {
    return MinhaFeature(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      isSync: map['is_sync'] ?? 0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'is_sync': isSync,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
```

### Passo 2: Criar o Repository
```dart
// lib/app/modules/[feature]/[feature].repository.dart
class MinhaFeatureRepository extends BaseRepository<MinhaFeature> {
  @override
  String get tableName => 'minha_feature';

  @override
  MinhaFeature fromMap(Map<String, dynamic> map) {
    return MinhaFeature().fromMap(map);
  }

  // Métodos específicos da feature
  Future<List<MinhaFeature>> findByNome(String nome) async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'nome LIKE ? AND ativo = ?',
      whereArgs: ['%$nome%', 1],
    );
    return result.map((map) => fromMap(map)).toList();
  }
}
```

### Passo 3: Criar o Provider
```dart
// lib/app/modules/[feature]/[feature].provider.dart
class MinhaFeatureProvider extends BaseProvider<MinhaFeature> {
  @override
  String get endpoint => '/rest/v1/minha_feature';

  @override
  Map<String, dynamic> toExternalFormat(MinhaFeature entity) {
    return {
      'id': entity.id,
      'nome': entity.nome,
      'descricao': entity.descricao,
      'ativo': entity.ativo,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  MinhaFeature fromExternalFormat(Map<String, dynamic> data) {
    return MinhaFeature(
      id: data['id'],
      nome: data['nome'],
      descricao: data['descricao'],
      isSync: 1, // Dados da API estão sincronizados
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  Future<bool> validateBeforeSync(MinhaFeature entity) async {
    return entity.nome.isNotEmpty && entity.descricao.isNotEmpty;
  }
}
```

### Passo 4: Criar o Schedule
```dart
// lib/app/modules/[feature]/[feature].schedule.dart
class MinhaFeatureSchedule extends BaseSchedule<MinhaFeature, MinhaFeatureRepository, MinhaFeatureProvider> {
  static final MinhaFeatureSchedule _instance = MinhaFeatureSchedule._init();
  factory MinhaFeatureSchedule() => _instance;

  MinhaFeatureSchedule._init() : super(
    MinhaFeatureRepository(), 
    MinhaFeatureProvider()
  );

  @override
  String get featureName => 'minha_feature';

  @override
  Duration get syncInterval => const Duration(minutes: 5);

  // Métodos específicos da feature
  Future<bool> syncByCategoria(String categoria) async {
    // Implementar lógica específica
    return true;
  }
}
```

### Passo 5: Registrar no ScheduleManager
```dart
// lib/app/core/services/schedule_manager.dart
Future<void> _autoRegisterSchedules() async {
  _schedules.addAll([
    UsuarioSchedule(),
    ClienteSchedule(),
    MinhaFeatureSchedule(), // ← Adicionar aqui
  ]);
}
```

### Passo 6: Adicionar ao Schema SQL
```sql
-- assets/sql/create_tables.sql
CREATE TABLE minha_feature (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    descricao TEXT NOT NULL,
    ativo INTEGER DEFAULT 1,
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 🎯 Padrões e Boas Práticas

### ✅ DO (Fazer)
- **Repository**: Use apenas `DbHelper` para persistência SQLite
- **Provider**: Use apenas `AppClient` para comunicação HTTP externa  
- **Schedule**: Herde de `BaseSchedule` e implemente `featureName`
- **Singleton**: Mantenha padrão singleton nos Schedules para consistência
- **Validações**: Implemente `validateBeforeSync` no Provider
- **Logs**: Use métodos `_logInfo` e `_logError` consistentes

### ❌ DON'T (Não Fazer)
- **Não misturar responsabilidades**: Repository não deve fazer HTTP, Provider não deve acessar SQLite
- **Não criar Schedules sem herança**: Sempre herdar de `BaseSchedule`
- **Não ignorar `isSync`**: Campo obrigatório para controle offline-first
- **Não esquecer validações**: Implementar validações antes de sincronizar

## 🚀 Uso Prático

### Inicialização no App
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SyncSystemInitializer.initialize();
  runApp(MyApp());
}
```

### Sincronização Manual
```dart
// Sincronizar todas features
await SyncSystemInitializer.forceSyncAll();

// Sincronizar feature específica
await SyncSystemInitializer.syncFeature('minha_feature');

// Usar schedule diretamente
await MinhaFeatureSchedule().syncNow();
```

### CRUD Offline-First
```dart
// Criar (sempre offline primeiro)
final entity = MinhaFeature(nome: 'Teste', descricao: 'Descrição');
await repository.insert(entity); // isSync = 0 automático

// O Schedule sincronizará automaticamente em background
```

## 🔄 Fluxo Completo

1. **Usuário cria/edita dados** → Salva no SQLite (isSync = 0)
2. **BaseSchedule detecta** → Busca pendências (`isSync = 0`)
3. **Provider valida** → `validateBeforeSync()`
4. **Provider sincroniza** → `syncToCloud()` via AppClient
5. **Repository atualiza** → Marca como sincronizado (isSync = 1)
6. **Schedule baixa atualizações** → `fetchFromCloud()` e resolve conflitos

## 📊 Monitoring e Debug

```dart
// Status do sistema
final status = ScheduleManager().getStatus();
print('Features ativas: ${status['schedules']}');

// Features registradas
final features = ScheduleManager().getRegisteredFeatures();
print('Features: ${features.join(', ')}');
```

Esta arquitetura garante:
- ✅ **Escalabilidade**: Adicionar features é simples e padronizado
- ✅ **Manutenibilidade**: Cada camada tem responsabilidade específica  
- ✅ **Offline-first**: SQLite é sempre a fonte primária
- ✅ **Background sync**: Sincronização automática e transparente
- ✅ **Type safety**: Generics garantem tipagem correta em toda arquitetura