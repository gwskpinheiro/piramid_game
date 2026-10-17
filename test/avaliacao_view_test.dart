import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:piramid_game/core/di/dependency_injection.dart';
import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/domain/facades/auth_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/avaliacao_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/pessoa_facade_usecases_interface.dart';
import 'package:piramid_game/domain/models/avaliacao_entity.dart';
import 'package:piramid_game/domain/models/pessoa_entity.dart';
import 'package:piramid_game/domain/models/usuario_entity.dart';
import 'package:piramid_game/presentation/controllers/auth_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/avaliacao_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/pessoa_viewmodel.dart';
import 'package:piramid_game/presentation/views/aluno/aluno_detalhe_view.dart';
import 'package:piramid_game/presentation/views/avaliacao/avaliacao_view.dart';

final _pessoa = Pessoa(
  id: 'p1', nome: 'João Teste', apelido: '', curso: Curso.tads, turmaAno: 2024,
  dataNascimento: DateTime(2000), criadoPor: 'u1',
  createdAt: DateTime(2024), updatedAt: DateTime(2024),
);

/// Facade falsa: simula o Firestore com pequenas latências.
class _FakeAvaliacaoFacade implements IAvaliacaoFacadeUseCases {
  /// Quando true, a verificação do vínculo falha (ex.: Firestore indisponível).
  bool falharVerificacao = false;

  @override
  Future<PermissaoAvaliacaoResult> verificarAutoavaliacao(PessoaIdParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (falharVerificacao) return Error(RemoteFailure('Servidor indisponível.'));
    return const Success(PermissaoAvaliacao.permitida);
  }

  @override
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(PessoaIdParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const Success(null);
  }

  @override
  Future<AvaliacaoResult> avaliar(AvaliarParams params) => throw UnimplementedError();
  @override
  Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params) => throw UnimplementedError();
}

class _FakePessoaFacade implements IPessoaFacadeUseCases {
  @override
  Future<ListPessoaResult> obterTodasPessoas(NoParams params) async => Success([_pessoa]);
  @override
  Future<PessoaResult> obterPessoaPorId(PessoaIdParams params) async => Success(_pessoa);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthFacade implements IAuthFacadeUseCases {
  @override
  Stream<Usuario?> observarUsuario(NoParams params) =>
      Stream.value(const Usuario(uid: 'u1', email: 'g@x.com'));
  @override
  Future<VoidResult> registrarPerfil(NoParams params) async => const Success(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _facade = _FakeAvaliacaoFacade();

GoRouter _router() => GoRouter(initialLocation: '/aluno-detalhe/p1', routes: [
      GoRoute(
        path: '/aluno-detalhe/:id', name: 'aluno_detalhe',
        pageBuilder: (c, s) => NoTransitionPage(child: AlunoDetalheView(alunoId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/avaliar/:id', name: 'avaliar',
        pageBuilder: (c, s) => NoTransitionPage(child: AvaliacaoView(pessoaId: s.pathParameters['id']!)),
      ),
    ]);

void main() {
  setUpAll(() async {
    injector.addInstance<AuthViewModel>(AuthViewModel(_FakeAuthFacade()));
    injector.addInstance<AvaliacaoViewModel>(AvaliacaoViewModel(_facade));
    injector.addInstance<PessoaViewModel>(PessoaViewModel(_FakePessoaFacade()));
    injector.commit();
    await injector.get<AuthViewModel>().iniciarMonitoramento();
    await injector.get<PessoaViewModel>().commands.carregarPessoas();
  });

  setUp(() => _facade.falharVerificacao = false);

  // Regressão: o carregamento era abortado por uma SignalEffectException ao
  // abrir /avaliar a partir dos detalhes, exibindo "Não foi possível carregar.".
  testWidgets('detalhes → Avaliar → voltar, sem exceções', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _router()));
    await tester.pumpAndSettle();

    expect(find.text('Avaliar'), findsOneWidget);
    await tester.tap(find.text('Avaliar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('1. Resenha'), findsOneWidget);
    expect(find.textContaining('Não foi possível'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Avaliar'), findsOneWidget);
  });

  testWidgets('falha ao verificar o vínculo mostra mensagem útil e permite tentar novamente',
      (tester) async {
    _facade.falharVerificacao = true;
    final router = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.go('/avaliar/p1');
    await tester.pumpAndSettle();

    expect(find.textContaining('Servidor indisponível.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    _facade.falharVerificacao = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('1. Resenha'), findsOneWidget);
  });
}
