import 'package:flutter/material.dart';
import 'package:serviceflow/demo_camera_page.dart';
import 'package:serviceflow/demo_signature_page.dart';
import 'package:serviceflow/menu_laboratorio_page.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const menuLab = '/menu-lab';
  static const demoCamera = '/demo-camera';
  static const demoSignature = '/demo-signature';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        menuLab: (context) => const MenuLaboratorioPage(),
        demoCamera: (context) => const DemoCameraPage(),
        demoSignature: (context) => const DemoSignaturePage(),
      };
}
