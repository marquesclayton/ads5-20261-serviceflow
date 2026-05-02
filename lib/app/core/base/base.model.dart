abstract class BaseModel {
  final int? id;
  final DateTime? createdAt;
  int isSync; // 0 = não sincronizado, 1 = sincronizado
  final bool ativo; // true = ativo, false = inativo (soft delete)

  BaseModel({
    this.id,
    this.createdAt,
    this.isSync = 0, // Por padrão não sincronizado (offline-first)
    this.ativo = true, // Por padrão ativo
  });

  // Construtor nomeado para criar a base a partir de um Map
  BaseModel.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int?,
        createdAt = map['created_at'] != null
            ? DateTime.tryParse(map['created_at'].toString())
            : null,
        isSync = (map['is_sync'] as int?) ?? 0,
        ativo = (map['ativo'] as int?) == 1; // SQLite usa 0/1 para bool

  // Método para converter os atributos da base para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'is_sync': isSync,
      'ativo': ativo ? 1 : 0, // SQLite usa 0/1 para bool
    };
  }
}
