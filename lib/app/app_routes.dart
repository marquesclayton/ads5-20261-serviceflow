import 'package:flutter/material.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(maxSeconds: 7),
        login: (_) => const LoginPage(),
      };
}
