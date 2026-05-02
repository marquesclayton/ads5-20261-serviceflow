import 'package:flutter/material.dart';
import 'package:serviceflow/demo_camera_page.dart';
import 'package:serviceflow/demo_signature_page.dart';
import 'package:serviceflow/menu_laboratorio_page.dart';
import 'package:serviceflow/test_icons_page.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/home/presentation/pages/home_page.dart';
import 'modules/clientes/presentation/pages/clientes_list_page.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_page.dart';
import 'modules/relatorios/presentation/pages/relatorios_page.dart';
import 'shared/pages/em_desenvolvimento_page.dart';
import 'modules/clientes/client.repository.dart';
import 'modules/clientes/cliente.service.dart';
import 'modules/clientes/cliente.validation.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const home = '/home';
  static const clientes = '/clientes';
  static const ordensServico = '/ordens-servico';
  static const relatorios = '/relatorios';
  static const novaOs = '/nova-os';
  static const buscar = '/buscar';
  static const pendentes = '/pendentes';
  static const configuracoes = '/configuracoes';
  static const estoque = '/estoque';
  static const fornecedores = '/fornecedores';
  static const menuLab = '/menu-lab';
  static const demoCamera = '/demo-camera';
  static const demoSignature = '/demo-signature';
  static const testIcons = '/test-icons';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),
        clientes: (_) {
          final repository = ClienteRepository();
          final validation = ClienteValidation(repository);
          final service = ClienteService(validation, repository);
          return ClientesListPage(service);
        },
        ordensServico: (_) => const OrdensServicoPage(),
        relatorios: (_) => const RelatoriosPage(),
        novaOs: (_) => const EmDesenvolvimentoPage(
              titulo: 'Nova Ordem de Serviço',
              icone: Icons.add_business,
              cor: Colors.blue,
              descricao: 'Funcionalidade de criar nova OS em desenvolvimento',
            ),
        buscar: (_) => const EmDesenvolvimentoPage(
              titulo: 'Buscar',
              icone: Icons.search,
              cor: Colors.teal,
              descricao: 'Funcionalidade de busca em desenvolvimento',
            ),
        pendentes: (_) => const EmDesenvolvimentoPage(
              titulo: 'Pendências',
              icone: Icons.pending_actions,
              cor: Colors.amber,
              descricao: 'Visualização de pendências em desenvolvimento',
            ),
        configuracoes: (_) => const EmDesenvolvimentoPage(
              titulo: 'Configurações',
              icone: Icons.settings,
              cor: Colors.grey,
              descricao: 'Configurações do sistema em desenvolvimento',
            ),
        estoque: (_) => const EmDesenvolvimentoPage(
              titulo: 'Estoque',
              icone: Icons.inventory,
              cor: Colors.teal,
              descricao: 'Funcionalidade de controle de estoque.\n'
                  'Gerencie produtos, peças e materiais\n'
                  'utilizados nas ordens de serviço.',
            ),
        fornecedores: (_) => const EmDesenvolvimentoPage(
              titulo: 'Fornecedores',
              icone: Icons.business,
              cor: Colors.indigo,
              descricao: 'Funcionalidade para cadastro de fornecedores.\n'
                  'Gerencie contatos e produtos\n'
                  'de seus parceiros comerciais.',
            ),
        menuLab: (context) => const MenuLaboratorioPage(),
        demoCamera: (context) => const DemoCameraPage(),
        demoSignature: (context) => const DemoSignaturePage(),
        testIcons: (context) => const TestIconsPage(),
      };
}
