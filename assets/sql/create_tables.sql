-- Tabela de Usuários (Cache local + dados específicos do app)
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    supabase_id TEXT NOT NULL UNIQUE, -- ID do Supabase (UUID)
    email TEXT NOT NULL UNIQUE,
    nome_completo TEXT NOT NULL,
    grupo_id TEXT NOT NULL,
    perfil TEXT DEFAULT 'tecnico', -- admin, tecnico, supervisor
    ultimo_login DATETIME,
    avatar_local_path TEXT,
    configuracoes TEXT, -- JSON das configurações do usuário
    ativo INTEGER DEFAULT 1, -- 1 = ativo, 0 = inativo (soft delete)
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Clientes
CREATE TABLE clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT NOT NULL,
    telefone TEXT NOT NULL,
    documento TEXT,
    endereco TEXT,
    cidade TEXT,
    estado TEXT,
    cep TEXT,
    ativo INTEGER DEFAULT 1, -- 1 = ativo, 0 = inativo (soft delete)
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- Tabela de Técnicos
CREATE TABLE tecnicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    especialidade TEXT,
    ativo INTEGER DEFAULT 1, -- 1 = ativo, 0 = inativo (soft delete)
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- Tabela de Catálogo de Serviços
CREATE TABLE servicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL,
    preco REAL NOT NULL,
    tempo_estimado TEXT,
    ativo INTEGER DEFAULT 1, -- 1 = ativo, 0 = inativo (soft delete)
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- Tabela de Ordem de Serviço (Cabeçalho)
CREATE TABLE ordens_servico (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    tecnico_id INTEGER NOT NULL,
    observacao TEXT,
    pecas_aplicadas TEXT,
    valor_pecas REAL DEFAULT 0,
    foto_antes TEXT,
    foto_depois TEXT,
    assinatura TEXT,
    ativo INTEGER DEFAULT 1, -- 1 = ativo, 0 = inativo (soft delete)
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes (id),
    FOREIGN KEY (tecnico_id) REFERENCES tecnicos (id)
);
-- Tabela de Itens da OS (Relacionamento N:N entre OS e Serviços)
-- Armazenamos o preço e descrição no momento da execução para histórico
CREATE TABLE os_itens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    os_id INTEGER NOT NULL,
    servico_id INTEGER NOT NULL,
    descricao_snapshot TEXT,
    preco_snapshot REAL,
    ativo INTEGER DEFAULT 1, -- 1 = ativo, 0 = inativo (soft delete)
    is_sync INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (os_id) REFERENCES ordens_servico (id),
    FOREIGN KEY (servico_id) REFERENCES servicos (id)
);

-- Tabela de Logs do Sistema (centralizada)
CREATE TABLE system_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    level TEXT NOT NULL, -- 'error', 'warning', 'info', 'debug'
    source TEXT NOT NULL, -- 'UsuarioProvider', 'ClienteProvider', etc.
    operation TEXT NOT NULL, -- 'syncToCloud', 'login', etc.
    message TEXT NOT NULL,
    stack_trace TEXT,
    metadata TEXT, -- JSON estruturado para contexto adicional
    is_sync INTEGER DEFAULT 0, -- Logs podem não precisar ser sincronizados
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
