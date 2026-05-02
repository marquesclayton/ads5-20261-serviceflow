import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/clientes/cliente.service.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.validation.dart';
import 'package:serviceflow/app/shared/widgets/custom_buttons.dart';
import 'package:serviceflow/app/shared/widgets/custom_dialogs.dart';
import 'package:serviceflow/app/shared/widgets/custom_cards.dart';
import 'package:serviceflow/app/shared/constants/app_icons.dart';

class ClientesListPage extends BaseController<Cliente, ClienteRepository,
    ClienteValidation, ClienteService> {
  ClientesListPage(super.service);

  @override
  Widget buildPage(BuildContext context, ClienteService service) {
    return ClientesListView(service: service);
  }
}

class ClientesListView extends StatefulWidget {
  final ClienteService service;

  const ClientesListView({super.key, required this.service});

  @override
  State<ClientesListView> createState() => _ClientesListViewState();
}

class _ClientesListViewState extends State<ClientesListView> {
  List<Cliente> _clientes = [];
  bool _isLoading = true;
  bool _mostrarInativos = true; // Por padrão, mostra todos

  // Getter para filtrar clientes baseado no estado
  List<Cliente> get _clientesFiltrados {
    if (_mostrarInativos) {
      return _clientes;
    } else {
      return _clientes.where((cliente) => cliente.ativo).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await widget.service.listar();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar clientes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              _mostrarInativos ? AppIcons.visibility : AppIcons.visibilityOff,
              color: Colors.white,
            ),
            onSelected: (value) {
              setState(() {
                _mostrarInativos = value == 'todos';
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'todos',
                child: Row(
                  children: [
                    Icon(
                      _mostrarInativos ? AppIcons.check : null,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    const Text('Mostrar Inativos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ativos',
                child: Row(
                  children: [
                    Icon(
                      !_mostrarInativos ? AppIcons.check : null,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    const Text('Apenas Ativos'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(AppIcons.refresh),
            onPressed: _carregarClientes,
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        tooltip: 'Adicionar Cliente',
        onPressed: () => Navigator.pushNamed(context, '/cliente/novo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clientesFiltrados.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _carregarClientes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = _clientesFiltrados[index];
                      return _buildClienteCard(cliente);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    final isEmpty = _clientes.isEmpty;
    final hasInactiveOnly =
        !isEmpty && _clientesFiltrados.isEmpty && !_mostrarInativos;

    return CustomEmptyStateCard(
      icon: isEmpty ? AppIcons.peopleOutline : AppIcons.visibilityOffOutlined,
      title: isEmpty
          ? 'Nenhum cliente cadastrado'
          : hasInactiveOnly
              ? 'Nenhum cliente ativo encontrado'
              : 'Nenhum cliente encontrado',
      message: isEmpty
          ? 'Toque no botão + para adicionar o primeiro cliente'
          : hasInactiveOnly
              ? 'Ative "Mostrar Inativos" para ver todos os clientes'
              : '',
      action: isEmpty
          ? CustomPrimaryButton(
              text: 'Adicionar Cliente',
              icon: AppIcons.add,
              onPressed: () => Navigator.pushNamed(context, '/cliente/novo'),
              width: null,
            )
          : null,
    );
  }

  Widget _buildClienteCard(Cliente cliente) {
    return CustomListCard(
      isActive: cliente.ativo,
      leading: CustomAvatarCard(
        initials: cliente.nome.isNotEmpty ? cliente.nome[0] : 'C',
        isActive: cliente.ativo,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              cliente.nome,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cliente.ativo ? null : Colors.grey[600],
                decoration: cliente.ativo ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          if (!cliente.ativo)
            CustomStatusCard(
              label: 'INATIVO',
              isActive: false,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cliente.email.isNotEmpty)
            Text(
              cliente.email,
              style: TextStyle(
                  color: cliente.ativo ? Colors.grey[600] : Colors.grey[400]),
            ),
          if (cliente.telefone.isNotEmpty)
            Text(
              cliente.telefone,
              style: TextStyle(
                  color: cliente.ativo ? Colors.grey[600] : Colors.grey[400]),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'editar':
              Navigator.pushNamed(context, '/cliente/editar',
                  arguments: cliente);
              break;
            case 'desativar':
              _confirmarDesativacao(cliente);
              break;
            case 'ativar':
              _reativarCliente(cliente);
              break;
            case 'excluir':
              _confirmarExclusao(cliente);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'editar',
            child: Row(
              children: [
                Icon(AppIcons.edit, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Editar'),
              ],
            ),
          ),
          if (cliente.ativo)
            PopupMenuItem(
              value: 'desativar',
              child: Row(
                children: [
                  Icon(AppIcons.inactive, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Desativar'),
                ],
              ),
            )
          else
            PopupMenuItem(
              value: 'ativar',
              child: Row(
                children: [
                  Icon(AppIcons.active, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Ativar'),
                ],
              ),
            ),
          PopupMenuItem(
            value: 'excluir',
            child: Row(
              children: [
                Icon(AppIcons.delete, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Excluir Permanente'),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _mostrarDetalhesCliente(cliente),
    );
  }

  void _mostrarDetalhesCliente(Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => CustomInfoDialog(
        title: cliente.nome,
        icon: AppIcons.person,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cliente.email.isNotEmpty)
              CustomInfoCard(
                icon: AppIcons.email,
                title: 'E-mail',
                value: cliente.email,
                showDivider: cliente.telefone.isNotEmpty || cliente.id != null,
              ),
            if (cliente.telefone.isNotEmpty)
              CustomInfoCard(
                icon: AppIcons.phone,
                title: 'Telefone',
                value: cliente.telefone,
                showDivider: cliente.id != null,
              ),
            if (cliente.id != null)
              CustomInfoCard(
                icon: AppIcons.info,
                title: 'ID',
                value: cliente.id.toString(),
                showDivider: false,
              ),
          ],
        ),
        actions: [
          CustomSecondaryButton(
            text: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            width: null,
          ),
          CustomActionButton(
            text: 'Editar',
            icon: AppIcons.edit,
            variant: CustomButtonVariant.primary,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/cliente/editar',
                  arguments: cliente);
            },
            width: null,
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(Cliente cliente) async {
    final confirmar = await CustomConfirmDialog.showDeleteConfirmation(
      context,
      itemName: 'o cliente ${cliente.nome}',
    );

    if (confirmar == true) {
      await _excluirCliente(cliente);
    }
  }

  void _confirmarDesativacao(Cliente cliente) async {
    final confirmar = await CustomConfirmDialog.showDeactivateConfirmation(
      context,
      itemName: 'o cliente ${cliente.nome}',
    );

    if (confirmar == true) {
      await _desativarCliente(cliente);
    }
  }

  Future<void> _excluirCliente(Cliente cliente) async {
    try {
      if (cliente.id != null) {
        await widget.service.delete(cliente.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente excluído com sucesso')),
        );
        _carregarClientes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir cliente: $e')),
      );
    }
  }

  Future<void> _desativarCliente(Cliente cliente) async {
    try {
      if (cliente.id != null) {
        await widget.service.softDelete(cliente.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente ${cliente.nome} desativado'),
            backgroundColor: Colors.orange,
          ),
        );
        _carregarClientes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao desativar cliente: $e')),
      );
    }
  }

  Future<void> _reativarCliente(Cliente cliente) async {
    try {
      if (cliente.id != null) {
        await widget.service.reactivate(cliente.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente ${cliente.nome} reativado'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarClientes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reativar cliente: $e')),
      );
    }
  }
}
