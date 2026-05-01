import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  // Padrão Singleton
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('serviceflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Definição da Tabela (DDL)
  Future _createDB(Database db, int version) async {
    // 1. Carrega o arquivo de texto dos assets
    final String script =
        await rootBundle.loadString('assets/sql/script_create_table.sql');

    // 2. Divide o arquivo por ponto e vírgula para executar comando por comando
    final List<String> commands = script.split(';');

    for (final command in commands) {
      if (command.trim().isNotEmpty) {
        await db.execute(command);
      }
    }
  }
}
