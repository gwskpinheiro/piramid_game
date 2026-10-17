import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart' as AppTheme;
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';
import 'presentation/controllers/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções geradas pelo FlutterFire CLI.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o factory correto do sqflite dependendo da plataforma.
  // No web, o sqflite padrão não funciona — usamos sqflite_common_ffi_web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  setupDependencyInjection();

  final themeController = injector.get<ThemeController>();

  // Restaura a sessão persistida pelo Firebase antes de montar as rotas.
  await injector.get<AuthViewModel>().iniciarMonitoramento();

  runApp(
    Watch(
      (_) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PiramidGame IFPR-Pgua',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        routerConfig: AppRouter.router,
      ),
    ),
  );
}
