class AppConfig {
  // 1. URL do seu projeto no Supabase
  // Exemplo: https://xyzabc.supabase.co
  static const String supabaseUrl = "https://mlcboockcxlqebrnxrim.supabase.co";

  // 2. Chave Anon/Public do seu projeto
  static const String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sY2Jvb2NrY3hscWVicm54cmltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NDY4NjMsImV4cCI6MjA5MTQyMjg2M30.UnsyR80NblMbKiD9wFMKeSaQCHymP1pi0V8L3ImuDr0";

  // 3. O "Crachá" do grupo atual (Manual para os alunos)
  // Eles devem alterar apenas esta string para o ID do grupo deles
  static const String groupId = "ADS3-2026-1-GP01";

  // Helper para verificar se a configuração está preenchida (opcional para debug)
  static bool get isConfigured =>
      supabaseUrl != "https://mlcboockcxlqebrnxrim.supabase.co" &&
      supabaseKey !=
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sY2Jvb2NrY3hscWVicm54cmltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NDY4NjMsImV4cCI6MjA5MTQyMjg2M30.UnsyR80NblMbKiD9wFMKeSaQCHymP1pi0V8L3ImuDr0";
}
