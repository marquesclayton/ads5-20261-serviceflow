import 'package:flutter/material.dart';

import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/clientes/cliente.service.dart';
import 'package:serviceflow/app/modules/clientes/cliente.validation.dart';

import '../../shared/widgets/widgets.dart';

class ClientePage extends BaseController<Cliente, ClienteRepository,
    ClienteValidation, ClienteService> {
  ClientePage(super.service);

  @override
  Widget buildPage(BuildContext context, ClienteService service) {
    return _ClientePageState(
      context: context,
      service: service,
      nomeController: TextEditingController(),
      emailController: TextEditingController(),
      telefonController: TextEditingController(),
      enderecoController: TextEditingController(),
      cidadeController: TextEditingController(),
      estadoController: TextEditingController(),
      cepController: TextEditingController(),
    );
  }
}

class _ClientePageState extends StatelessWidget {
  final BuildContext context;
  final ClienteService service;
  final Cliente cliente = Cliente(nome: '', email: '', telefone: '');

  late final TextEditingController nomeController;
  late final TextEditingController emailController;
  late final TextEditingController telefonController;
  late final TextEditingController enderecoController;
  late final TextEditingController cidadeController;
  late final TextEditingController estadoController;
  late final TextEditingController cepController;

  _ClientePageState({
    required this.context,
    required this.service,
    required this.nomeController,
    required this.emailController,
    required this.telefonController,
    required this.enderecoController,
    required this.cidadeController,
    required this.estadoController,
    required this.cepController,
  }) {
    nomeController = TextEditingController(text: cliente.nome);
    emailController = TextEditingController(text: cliente.email);
    telefonController = TextEditingController(text: cliente.telefone);
    enderecoController = TextEditingController(text: cliente.endereco);
    cidadeController = TextEditingController(text: cliente.cidade);
    estadoController = TextEditingController(text: cliente.estado);
    cepController = TextEditingController(text: cliente.cep);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cliente.id != null ? 'Editar Cliente' : 'Novo Cliente',
        ),
        leading: IconButton(
          icon: Icon(AppIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: nomeController,
                label: 'Nome',
                prefixIcon: AppIcons.person,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                label: 'Email',
                prefixIcon: AppIcons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: telefonController,
                label: 'Telefone',
                prefixIcon: AppIcons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Telefone é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: enderecoController,
                label: 'Endereço',
                prefixIcon: AppIcons.location,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Endereço é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: cidadeController,
                label: 'Cidade',
                prefixIcon: AppIcons.location,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Cidade é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: estadoController,
                label: 'Estado',
                prefixIcon: AppIcons.map,
                maxLength: 2,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Estado é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: cepController,
                label: 'CEP',
                prefixIcon: AppIcons.location,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'CEP é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomPrimaryButton(
                text: cliente.id != null ? 'Atualizar' : 'Salvar',
                icon: AppIcons.save,
                onPressed: () {
                  // Lógica para salvar o cliente
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
