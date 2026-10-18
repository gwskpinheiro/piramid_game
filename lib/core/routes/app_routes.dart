import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/vinculo_viewmodel.dart';
import '../../presentation/views/aluno/aluno_detalhe_view.dart';
import '../../presentation/views/aluno/aluno_form_view.dart';
import '../../presentation/views/aluno/alunos_list_view.dart';
import '../../presentation/views/auth/cadastro_view.dart';
import '../../presentation/views/auth/identificacao_view.dart';
import '../../presentation/views/avaliacao/avaliacao_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/ranking/ranking_view.dart';
import '../../presentation/views/sobre_view.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/home_view.dart';

class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const cadastro = 'cadastro';
  static const identificacao = 'identificacao';
  static const home = 'home';
  static const alunos = 'alunos';
  static const alunoForm = 'aluno_form';
  static const alunoDetalhe = 'aluno_detalhe';
  static const ranking = 'ranking';
  static const sobre = 'sobre';
  static const avaliar = 'avaliar';
}

/// Converte os signals de autenticação e de vínculo em um Listenable para o
/// go_router reavaliar o redirect sempre que o usuário entra, sai ou se vincula.
class _AuthRefreshListenable extends ChangeNotifier {
  late final void Function() _disposeEffect;

  _AuthRefreshListenable(List<ReadonlySignal<Object?>> sinais) {
    _disposeEffect = effect(() {
      for (final s in sinais) {
        s.value;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposeEffect();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static const _rotasPublicas = {'/login', '/cadastro'};
  static const _identificacao = '/identificacao';

  static final _authState = injector.get<AuthViewModel>().authState;
  static final _vinculo = injector.get<VinculoViewModel>();

  /// Fluxo: Login → identificação do próprio perfil (se ainda sem vínculo) → Home.
  /// [possuiVinculo] null = ainda verificando (a tela de identificação aguarda).
  static String? decidirRedirect({
    required String loc,
    required bool logado,
    required bool? possuiVinculo,
  }) {
    if (loc == '/') return null; // splash decide o próximo passo
    final publica = _rotasPublicas.contains(loc);
    if (!logado) return publica ? null : '/login';
    final vinculado = possuiVinculo == true;
    if (publica) return vinculado ? '/home' : _identificacao;
    if (!vinculado && loc != _identificacao) return _identificacao;
    if (vinculado && loc == _identificacao) return '/home';
    return null;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable:
        _AuthRefreshListenable([_authState.isAutenticado, _vinculo.possuiVinculo]),
    redirect: (context, state) => decidirRedirect(
      loc: state.matchedLocation,
      logado: _authState.isAutenticado.value,
      possuiVinculo: _vinculo.possuiVinculo.value,
    ),
    routes: [
      GoRoute(path: '/', name: AppRouteNames.splash, pageBuilder: (c, s) => const NoTransitionPage(child: SplashView())),
      GoRoute(path: '/login', name: AppRouteNames.login, pageBuilder: (c, s) => const NoTransitionPage(child: LoginView())),
      GoRoute(path: '/cadastro', name: AppRouteNames.cadastro, pageBuilder: (c, s) => const NoTransitionPage(child: CadastroView())),
      GoRoute(path: '/identificacao', name: AppRouteNames.identificacao, pageBuilder: (c, s) => const NoTransitionPage(child: IdentificacaoView())),
      GoRoute(path: '/home', name: AppRouteNames.home, pageBuilder: (c, s) => const NoTransitionPage(child: HomeView())),
      GoRoute(path: '/alunos', name: AppRouteNames.alunos, pageBuilder: (c, s) => const NoTransitionPage(child: AlunosListView())),
      GoRoute(path: '/aluno-form', name: AppRouteNames.alunoForm, pageBuilder: (c, s) => const NoTransitionPage(child: AlunoFormView(alunoId: null))),
      GoRoute(path: '/aluno-form/:id', name: 'aluno_form_edit', pageBuilder: (c, s) => NoTransitionPage(child: AlunoFormView(alunoId: s.pathParameters['id']!))),
      GoRoute(path: '/aluno-detalhe/:id', name: AppRouteNames.alunoDetalhe, pageBuilder: (c, s) => NoTransitionPage(child: AlunoDetalheView(alunoId: s.pathParameters['id']!))),
      GoRoute(path: '/avaliar/:id', name: AppRouteNames.avaliar, pageBuilder: (c, s) => NoTransitionPage(child: AvaliacaoView(pessoaId: s.pathParameters['id']!))),
      GoRoute(path: '/ranking', name: AppRouteNames.ranking, pageBuilder: (c, s) => NoTransitionPage(child: RankingView(abaInicial: s.uri.queryParameters['aba'] == 'global' ? 1 : 0))),
      GoRoute(path: '/sobre', name: AppRouteNames.sobre, pageBuilder: (c, s) => const NoTransitionPage(child: SobreView())),
    ],
  );
}
