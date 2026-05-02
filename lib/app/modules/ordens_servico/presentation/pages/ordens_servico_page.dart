import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/pages/em_desenvolvimento_page.dart';

class OrdensServicoPage extends StatelessWidget {
  const OrdensServicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmDesenvolvimentoPage(
      titulo: 'Ordens de Serviço',
      icone: Icons.build,
      cor: Colors.green,
      descricao: 'Funcionalidade para criar e gerenciar Ordens de Serviço.\n'
          'Aqui você poderá cadastrar serviços, anexar fotos,\n'
          'capturar assinaturas e acompanhar o status.',
    );
  }
}