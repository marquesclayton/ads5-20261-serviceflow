# 🏗️ Guia de Implementação - Arquitetura BaseProvider + BaseSchedule

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