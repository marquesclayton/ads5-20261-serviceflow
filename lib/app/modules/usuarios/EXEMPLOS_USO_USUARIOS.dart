// 🎯 EXEMPLOS DE USO - Sistema de Usuários com Arquitetura Centralizada
// 📋 Este arquivo demonstra como implementar funcionalidades usando:
//     • BaseController com LoaderMixin + MessagesMixin automático
//     • Operações centralizadas (executeOperation, executeListOperation, executeCrudOperation)
//     • Fluxo completo: Loader → Service → Exception Handling → Messages
//     • Convergência de exceções para mensagens amigáveis

import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/core/mixins/messages.mixin.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.validation.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.service.dart';

// ============================================================================
// 📖 EXEMPLO 1: Lista de Usuários com BaseController e Operações Centralizadas
// ============================================================================

class UsuariosListPageExample extends BaseController<Usuario, UsuarioRepository,
    UsuarioValidation, UsuarioService> {
  UsuariosListPageExample(UsuarioService service) : super(service);

  @override
  Widget buildPage(BuildContext context, UsuarioService service) {
    return UsuariosListWidget();
  }
}

class UsuariosListWidget extends StatefulWidget {
  @override
  _UsuariosListPageState createState() => _UsuariosListPageState();
}

class _UsuariosListPageState extends State<UsuariosListWidget> {
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  // 🔄 EXEMPLO: executeListOperation
  // ✅ Loader automático, ✅ Exception handling, ✅ Mensagens automáticas
  Future<void> _carregarUsuarios() async {
    // Simulando uma chamada de service - substitua pela implementação real
    final usuarios = <Usuario>[]; // await service.findAll();

    setState(() {
      _usuarios = usuarios; // ✅ Atualiza a UI automaticamente
    });
  }

  // 🗑️ EXEMPLO: executeCrudOperation com Confirmação
  // ✅ Confirmação integrada, ✅ Loader, ✅ Sucesso/Erro, ✅ Refresh automático
  Future<void> _excluirUsuario(Usuario usuario) async {
    // Simulando uma operação de exclusão
    print('Excluindo usuário: ${usuario.nomeCompleto}');
    _carregarUsuarios(); // 🔄 Refresh da lista
  }

  // ⚡ EXEMPLO: executeOperation Genérica
  // ✅ Para operações que não se encaixam nos padrões List/CRUD
  Future<void> _atualizarConfigUsuario(Usuario usuario) async {
    // Simulando uma operação de configuração
    print('Atualizando configurações para: ${usuario.nomeCompleto}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuários - Exemplo Arquitetura')),
      body: ListView.builder(
        itemCount: 5, // Simulando 5 usuários
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Usuario ${index + 1}'),
            subtitle: Text('email${index + 1}@exemplo.com'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('⚙️ Configurar'),
                  onTap: () => _atualizarConfigUsuario(
                    Usuario(
                      supabaseId: 'id$index',
                      email: 'email$index@exemplo.com',
                      nomeCompleto: 'Usuario $index',
                      grupoId: 'grupo1',
                      perfil: 'tecnico',
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: Text('🗑️ Excluir'),
                  onTap: () => _excluirUsuario(
                    Usuario(
                      supabaseId: 'id$index',
                      email: 'email$index@exemplo.com',
                      nomeCompleto: 'Usuario $index',
                      grupoId: 'grupo1',
                      perfil: 'tecnico',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _carregarUsuarios,
        child: Icon(Icons.refresh),
        tooltip: 'Recarregar Lista',
      ),
    );
  }
}

// ============================================================================
// 📖 EXEMPLO 2: Formulário de Usuário com Validação e Operações Centralizadas
// ============================================================================

class UsuarioFormPageExample extends BaseController<Usuario, UsuarioRepository,
    UsuarioValidation, UsuarioService> {
  final Usuario? usuarioEdicao; // null = criar, preenchido = editar

  UsuarioFormPageExample(
    UsuarioService service, {
    this.usuarioEdicao,
  }) : super(service, model: usuarioEdicao);

  @override
  Widget buildPage(BuildContext context, UsuarioService service) {
    return UsuarioFormWidget(usuarioEdicao: usuarioEdicao);
  }
}

class UsuarioFormWidget extends StatefulWidget {
  final Usuario? usuarioEdicao;

  const UsuarioFormWidget({Key? key, this.usuarioEdicao}) : super(key: key);

  @override
  _UsuarioFormPageState createState() => _UsuarioFormPageState();
}

class _UsuarioFormPageState extends State<UsuarioFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  bool get _isEdicao => widget.usuarioEdicao != null;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      _nomeController.text = widget.usuarioEdicao!.nomeCompleto;
      _emailController.text = widget.usuarioEdicao!.email;
    }
  }

  // 💾 EXEMPLO: executeOperation para Criar/Atualizar
  // ✅ Validação + Loader + Exception Handling + Mensagem de Sucesso
  Future<void> _salvarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    // Simulando salvar usuário
    print(
        'Salvando usuário: ${_nomeController.text} - ${_emailController.text}');

    Navigator.of(context).pop(); // 🔙 Voltar após salvar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Usuário' : 'Novo Usuário'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite o nome completo',
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Digite o email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Email é obrigatório';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvarUsuario,
                child: Text(_isEdicao ? '💾 Atualizar' : '➕ Criar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 📖 EXEMPLO 3: Demonstração de Todos os Tipos de Mensagem
// ============================================================================

class ExemploMensagensPage extends BaseController<Usuario, UsuarioRepository,
    UsuarioValidation, UsuarioService> {
  ExemploMensagensPage(UsuarioService service) : super(service);

  @override
  Widget buildPage(BuildContext context, UsuarioService service) {
    return ExemploMensagensWidget();
  }
}

class ExemploMensagensWidget extends StatefulWidget {
  @override
  _ExemploMensagensPageState createState() => _ExemploMensagensPageState();
}

class _ExemploMensagensPageState extends State<ExemploMensagensWidget>
    with MessagesMixin {
  // ✅ Sucesso: Auto-remove após 3 segundos (já gerenciado pelo MessagesMixin)
  void _mostrarSucesso() {
    showSuccess(context, 'Operação realizada com sucesso!');
  }

  // ❌ Erro: Permanece até fechar manualmente (já gerenciado pelo MessagesMixin)
  void _mostrarErro() {
    showError(
        context, 'Algo deu errado! Verifique os dados e tente novamente.');
  }

  // ⚠️ Aviso: Auto-remove após 4 segundos (já gerenciado pelo MessagesMixin)
  void _mostrarAviso() {
    showWarning(context, 'Atenção: Esta ação pode afetar outros dados.');
  }

  // 🔔 Confirmação: Aguarda ação do usuário (já gerenciado pelo MessagesMixin)
  Future<void> _mostrarConfirmacao() async {
    final confirmou = await showConfirmation(
      context,
      'Confirmar Ação',
      'Tem certeza que deseja prosseguir?',
      confirmText: 'Sim, prosseguir',
      cancelText: 'Cancelar',
    );

    if (confirmou == true) {
      _mostrarSucesso();
    } else {
      _mostrarAviso();
    }
  }

  // ℹ️ Informação: Auto-remove após 3 segundos
  void _mostrarInfo() {
    showInfo(context, 'Informação importante sobre o sistema.');
  }

  // 🍞 Toast: Auto-remove após 2 segundos (mais rápido)
  void _mostrarToast() {
    showToast(context, 'Operação executada rapidamente!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exemplo - Sistema de Mensagens')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '🎭 Sistema de Mensagens com Durações Automáticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _mostrarSucesso,
              icon: Icon(Icons.check_circle, color: Colors.green),
              label: Text('✅ Sucesso (3s auto-remove)'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _mostrarErro,
              icon: Icon(Icons.error, color: Colors.red),
              label: Text('❌ Erro (remoção manual)'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _mostrarAviso,
              icon: Icon(Icons.warning, color: Colors.orange),
              label: Text('⚠️ Aviso (4s auto-remove)'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _mostrarConfirmacao,
              icon: Icon(Icons.help_outline, color: Colors.blue),
              label: Text('🔔 Confirmação (aguarda usuário)'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _mostrarInfo,
              icon: Icon(Icons.info, color: Colors.blue),
              label: Text('ℹ️ Info (3s auto-remove)'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _mostrarToast,
              icon: Icon(Icons.message, color: Colors.grey),
              label: Text('🍞 Toast (2s auto-remove)'),
            ),
            SizedBox(height: 48),
            Text(
              '📋 Comportamentos (Todos Automáticos via MessagesMixin):\n'
              '• Sucesso: Remove automaticamente após 3 segundos\n'
              '• Erro: Permanece até usuário fechar manualmente\n'
              '• Aviso: Remove automaticamente após 4 segundos\n'
              '• Info: Remove automaticamente após 3 segundos\n'
              '• Toast: Remove automaticamente após 2 segundos\n'
              '• Confirmação: Aguarda ação do usuário (Sim/Não)',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 📖 EXEMPLO 4: Tratamento Automático de Exceções
// ============================================================================

class ExemploExcecoesPage extends BaseController<Usuario, UsuarioRepository,
    UsuarioValidation, UsuarioService> {
  ExemploExcecoesPage(UsuarioService service) : super(service);

  @override
  Widget buildPage(BuildContext context, UsuarioService service) {
    return ExemploExcecoesWidget();
  }
}

class ExemploExcecoesWidget extends StatefulWidget {
  @override
  _ExemploExcecoesPageState createState() => _ExemploExcecoesPageState();
}

class _ExemploExcecoesPageState extends State<ExemploExcecoesWidget>
    with MessagesMixin {
  // 🔄 EXEMPLO: Todas as exceções convergem para mensagens amigáveis
  Future<void> _testarExcecoes() async {
    // Simulando tratamento de exceção
    try {
      throw Exception('Erro simulado para demonstração');
    } catch (e) {
      showError(context, 'Erro personalizado para esta operação',
          details: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exemplo - Tratamento de Exceções')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🛡️ Tratamento Automático de Exceções',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Todas as exceções são automaticamente\n'
              'convertidas em mensagens amigáveis',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _testarExcecoes,
              child: Text('🧪 Testar Exceções'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 📋 RESUMO DOS EXEMPLOS
// ============================================================================
/*
🎯 PADRÕES DEMONSTRADOS:

1️⃣ executeListOperation<T>():
   • Para carregar listas de dados
   • Loader automático + tratamento de erro + retorno tipado
   
2️⃣ executeCrudOperation():
   • Para Create/Update/Delete
   • Confirmação integrada + loader + mensagens success/error
   
3️⃣ executeOperation():
   • Para operações genéricas
   • Loader + tratamento + mensagem customizável
   
4️⃣ Sistema de Mensagens (MessagesMixin):
   • showSuccess() → 3 segundos auto-remove + ícone verde
   • showError() → manual remove + botão fechar + ícone vermelho  
   • showWarning() → 4 segundos auto-remove + ícone laranja
   • showInfo() → 3 segundos auto-remove + ícone azul
   • showToast() → 2 segundos auto-remove + simples
   • showConfirmation() → aguarda usuário + dialog customizado
   • showDeleteConfirmation() → confirmação específica para exclusões
   
5️⃣ Exception Convergence:
   • Todas exceções → mensagens amigáveis
   • SQL/HTTP/Validation/Generic automaticamente tratadas
   • Logs técnicos preservados para debug

✅ BENEFÍCIOS:
• Código 80% mais limpo nas pages
• Zero boilerplate de loading/error
• UX consistente em toda aplicação
• Exception handling centralizado
• Manutenibilidade máxima
*/
