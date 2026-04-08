import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../app_routes.dart';

class SplashPage extends StatefulWidget {
  final int maxSeconds;
  const SplashPage({super.key, this.maxSeconds = 7});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: widget.maxSeconds), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
            ],
          ),
        ),
      ),
    );
  }
}
