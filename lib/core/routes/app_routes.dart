import 'package:go_router/go_router.dart';

import '../../presentation/views/aluno/aluno_detalhe_view.dart';
import '../../presentation/views/aluno/aluno_form_view.dart';
import '../../presentation/views/aluno/alunos_list_view.dart';
import '../../presentation/views/ranking/ranking_view.dart';
import '../../presentation/views/sobre_view.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/home_view.dart';

class AppRouteNames {
  static const splash = 'splash';
  static const home = 'home';
  static const alunos = 'alunos';
  static const alunoForm = 'aluno_form';
  static const alunoDetalhe = 'aluno_detalhe';
  static const ranking = 'ranking';
  static const sobre = 'sobre';
}

class AppPaths {
  static const splash = '/';
  static const home = '/home';
  static const alunos = '/alunos';
  static const alunoForm = '/aluno-form';
  static const alunoFormEdit = '/aluno-form/:id';
  static const alunoDetalhe = '/aluno-detalhe/:id';
  static const ranking = '/ranking';
  static const sobre = '/sobre';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,
    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRouteNames.splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashView()),
      ),
      GoRoute(
        path: AppPaths.home,
        name: AppRouteNames.home,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeView()),
      ),
      GoRoute(
        path: AppPaths.alunos,
        name: AppRouteNames.alunos,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AlunosListView()),
      ),
      // Cadastro (sem ID)
      GoRoute(
        path: AppPaths.alunoForm,
        name: AppRouteNames.alunoForm,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AlunoFormView(alunoId: null)),
      ),
      // Edição (com ID)
      GoRoute(
        path: AppPaths.alunoFormEdit,
        name: 'aluno_form_edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: AlunoFormView(alunoId: id));
        },
      ),
      GoRoute(
        path: AppPaths.alunoDetalhe,
        name: AppRouteNames.alunoDetalhe,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: AlunoDetalheView(alunoId: id));
        },
      ),
      GoRoute(
        path: AppPaths.ranking,
        name: AppRouteNames.ranking,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: RankingView()),
      ),
      GoRoute(
        path: AppPaths.sobre,
        name: AppRouteNames.sobre,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SobreView()),
      ),
    ],
  );
}
