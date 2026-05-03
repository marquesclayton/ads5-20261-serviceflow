import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

class DbHelper {
  // 1. Instância privada para o Singleton
  static final DbHelper instance = DbHelper._init();

  // 2. O objeto da conexão
  static Database? _database;

  // 3. Construtor privado (ninguém fora da classe pode dar 'new DbHelper()')
  DbHelper._init();

// 4. Getter para obter a conexão (Lazy Initialization)
  Future<Database> get database async {
    // Se já existe uma conexão, retorna ela
    if (_database != null) return _database!;

    // Caso contrário, inicializa o banco
    _database = await _initDB('serviceflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Busca o diretório padrão de bancos de dados do SO (Android/iOS)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Controle de versão para futuras atualizações
      onCreate: _onCreate,
    );
  }

  // 5. O momento da criação das tabelas
  Future _onCreate(Database db, int version) async {
    print('🔄 Criando tabelas do banco de dados...');

    try {
      // Lê o arquivo texto dos assets que definimos
      final String script =
          await rootBundle.loadString('assets/sql/create_tables.sql');

      // Divide os comandos por ponto e vírgula
      final List<String> commands = script.split(';');

      // Executa cada comando individualmente
      for (final command in commands) {
        final trimmedCommand = command.trim();
        if (trimmedCommand.isNotEmpty) {
          try {
            await db.execute(trimmedCommand);
          } catch (e) {
            print('❌ Erro ao executar comando SQL: $trimmedCommand');
            print('❌ Erro: $e');
            rethrow; // Propagar o erro para não deixar banco inconsistente
          }
        }
      }

      print('✅ Banco de dados criado com sucesso');
    } catch (e, stackTrace) {
      print('❌ ERRO CRÍTICO ao criar tabelas: $e');
      print('📋 Stack: $stackTrace');
      rethrow; // Importante: não deixar a aplicação rodar com banco corrompido
    }
  }
}
