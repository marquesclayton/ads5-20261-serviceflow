import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/pages/em_desenvolvimento_page.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmDesenvolvimentoPage(
      titulo: 'Relatórios',
      icone: Icons.bar_chart,
      cor: Colors.orange,
      descricao: 'Funcionalidade para visualização de relatórios e métricas.\n'
          'Aqui você poderá gerar relatórios de clientes,\n'
          'ordens de serviço e estatísticas do sistema.',
    );
  }
}
