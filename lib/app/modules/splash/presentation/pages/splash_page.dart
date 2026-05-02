import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/helpers/database_helper.dart';
import 'package:serviceflow/app/shared/widgets/app_logo.dart';
import 'package:serviceflow/app/core/services/auth.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.schedule.dart';

import '../../../../app_routes.dart';

class SplashPage extends StatefulWidget {
  final int maxSeconds;
  const SplashPage({super.key, this.maxSeconds = 3});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await DbHelper.instance.database;
      if (!mounted) return;
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Erro ao inicializar banco de dados: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => _closeApp(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _closeApp() {
    Navigator.of(context).pop();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: widget.maxSeconds), () {
      if (!mounted) return;
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() async {
    final authService = AuthService();
    
    try {
      // Verificar se há sessão válida (Supabase + cache local)
      final hasSession = await authService.hasValidSession();
      
      if (hasSession) {
        // Usuário logado - iniciar agendador e ir para menu principal
        final UsuarioSchedule schedule = UsuarioSchedule();
        schedule.start(); // Iniciar sincronização em background
        
        Navigator.of(context).pushReplacementNamed(AppRoutes.menuLab);
      } else {
        // Usuário não logado - ir para login
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      print("❌ Erro ao verificar autenticação: $e");
      // Em caso de erro, ir para login
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 222, 231, 246),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('ServiceFlow', style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Text('Carregando...'),
              SizedBox(height: 35),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppLogo(width: double.infinity, height: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
