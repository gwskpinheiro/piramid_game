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

class AppRouter {
  AppRouter._();
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', name: AppRouteNames.splash, pageBuilder: (c, s) => const NoTransitionPage(child: SplashView())),
      GoRoute(path: '/home', name: AppRouteNames.home, pageBuilder: (c, s) => const NoTransitionPage(child: HomeView())),
      GoRoute(path: '/alunos', name: AppRouteNames.alunos, pageBuilder: (c, s) => const NoTransitionPage(child: AlunosListView())),
      GoRoute(path: '/aluno-form', name: AppRouteNames.alunoForm, pageBuilder: (c, s) => const NoTransitionPage(child: AlunoFormView(alunoId: null))),
      GoRoute(path: '/aluno-form/:id', name: 'aluno_form_edit', pageBuilder: (c, s) => NoTransitionPage(child: AlunoFormView(alunoId: s.pathParameters['id']!))),
      GoRoute(path: '/aluno-detalhe/:id', name: AppRouteNames.alunoDetalhe, pageBuilder: (c, s) => NoTransitionPage(child: AlunoDetalheView(alunoId: s.pathParameters['id']!))),
      GoRoute(path: '/ranking', name: AppRouteNames.ranking, pageBuilder: (c, s) => const NoTransitionPage(child: RankingView())),
      GoRoute(path: '/sobre', name: AppRouteNames.sobre, pageBuilder: (c, s) => const NoTransitionPage(child: SobreView())),
    ],
  );
}
