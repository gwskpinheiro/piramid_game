import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart' as AppTheme;
import 'firebase_options.dart';
import 'presentation/controllers/auth_viewmodel.dart';
import 'presentation/controllers/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções geradas pelo FlutterFire CLI.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupDependencyInjection();

  // Recupera o tema salvo (SharedPreferences) antes de exibir a interface.
  final themeViewModel = injector.get<ThemeViewModel>();
  await themeViewModel.carregarTema();

  // Restaura a sessão persistida pelo Firebase antes de montar as rotas.
  await injector.get<AuthViewModel>().iniciarMonitoramento();

  runApp(
    Watch(
      (_) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PiramidGame IFPR-Pgua',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeViewModel.themeMode.value,
        routerConfig: AppRouter.router,
      ),
    ),
  );
}
