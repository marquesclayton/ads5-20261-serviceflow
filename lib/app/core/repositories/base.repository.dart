import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base.model.dart';

abstract class BaseRepository<E extends BaseModel> {
  // 1. Centralização do Client (Busca a instância única do Supabase)
  SupabaseClient get client => Supabase.instance.client;

  // 2. Centralização do GroupId (O aluno só altera aqui uma vez na vida)
  String get _groupId => 'SF-GP-01';

  // 3. O filho é obrigado a dizer apenas o nome da tabela
  String get tableName;

  E fromJson(Map<String, dynamic> json);

  Future<List<E>> getAll() async {
    final response = await client
        .from(tableName)
        .select()
        .eq('group_id', _groupId) // Uso interno e automático
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => fromJson(json)).toList();
  }

  Future<void> create(E entity) async {
    final data = entity.toMap();
    data['group_id'] = _groupId; // Injeção automática no cadastro
    await client.from(tableName).insert(data);
  }

  // ... demais métodos (getById, delete) seguem a mesma lógica
}