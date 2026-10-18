import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:piramid_game/core/di/dependency_injection.dart';
import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/domain/facades/auth_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/avaliacao_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/pessoa_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/ranking_facade_usecases_interface.dart';
import 'package:piramid_game/domain/models/avaliacao_entity.dart';
import 'package:piramid_game/domain/models/pessoa_entity.dart';
import 'package:piramid_game/domain/models/ranking_entity.dart';
import 'package:piramid_game/domain/models/usuario_entity.dart';
import 'package:piramid_game/presentation/controllers/auth_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/avaliacao_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/pessoa_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/ranking_viewmodel.dart';
import 'package:piramid_game/presentation/views/ranking/ranking_view.dart';

// ── Dados ──────────────────────────────────────────────────────────────────
const _a = Usuario(uid: 'uidA', email: 'a@x.com');
const _b = Usuario(uid: 'uidB', email: 'b@x.com');

Pessoa _p(String nome) => Pessoa(
      id: nome, nome: nome, apelido: '', curso: Curso.tads, turmaAno: 2024,
      dataNascimento: DateTime(2000), criadoPor: 'x',
      createdAt: DateTime(2024), updatedAt: DateTime(2024),
    );

List<ItemRanking> _ranking(List<String> nomes) => [
      for (var i = 0; i < nomes.length; i++)
        ItemRanking(pessoa: _p(nomes[i]), posicao: i + 1,
            somaPontuacoes: 70 - i, quantidadeAvaliacoes: 1),
    ];

Avaliacao _avaliacao(String pessoaId, String uid) => Avaliacao(
      id: Avaliacao.gerarId(pessoaId, uid), pessoaId: pessoaId, avaliadorUid: uid,
      criterios: const CriteriosPopularidade(resenha: 5, aura: 5),
      createdAt: DateTime(2026), dataAvaliacao: DateTime(2026),
    );

// ── Fakes controláveis: cada chamada fica pendente até o teste completá-la ──
class _FakeAuth implements IAuthFacadeUseCases {
  final controller = StreamController<Usuario?>.broadcast();
  @override
  Stream<Usuario?> observarUsuario(NoParams params) => controller.stream;
  @override
  Future<VoidResult> registrarPerfil(NoParams params) async => const Success(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRanking implements IRankingFacadeUseCases {
  final pessoal = <Completer<RankingResult>>[];
  @override
  Future<RankingResult> gerarRankingPessoal(NoParams params) {
    final c = Completer<RankingResult>();
    pessoal.add(c);
    return c.future;
  }

  @override
  Future<RankingResult> gerarRankingGlobal(NoParams params) async =>
      Success(_ranking(['Global1', 'Global2']));
}

class _FakeAvaliacao implements IAvaliacaoFacadeUseCases {
  final verificar = <Completer<PermissaoAvaliacaoResult>>[];
  final consultar = <Completer<AvaliacaoOpcionalResult>>[];
  @override
  Future<PermissaoAvaliacaoResult> verificarAutoavaliacao(PessoaIdParams params) {
    final c = Completer<PermissaoAvaliacaoResult>();
    verificar.add(c);
    return c.future;
  }

  @override
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(PessoaIdParams params) {
    final c = Completer<AvaliacaoOpcionalResult>();
    consultar.add(c);
    return c.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePessoa implements IPessoaFacadeUseCases {
  final todas = <Completer<ListPessoaResult>>[];
  @override
  Future<ListPessoaResult> obterTodasPessoas(NoParams params) {
    final c = Completer<ListPessoaResult>();
    todas.add(c);
    return c.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeAuth authFacade;
  late AuthViewModel auth;

  Future<void> entrar(Usuario? u) async {
    authFacade.controller.add(u);
    await pumpEventQueue();
  }

  setUp(() async {
    authFacade = _FakeAuth();
    auth = AuthViewModel(authFacade);
    final pronto = auth.iniciarMonitoramento();
    authFacade.controller.add(_a);
    await pronto;
  });

  group('Ranking pessoal', () {
    late _FakeRanking facade;
    late RankingViewModel vm;

    setUp(() {
      facade = _FakeRanking();
      vm = RankingViewModel(facade, auth);
    });

    test('logout remove o ranking pessoal e preserva o global', () async {
      final carregando = vm.commands.carregarRankingPessoal();
      facade.pessoal.last.complete(Success(_ranking(['DoA'])));
      await carregando;
      await vm.commands.carregarRankingGlobal();
      expect(vm.rankingState.rankingPessoal.value.single.pessoa.nome, 'DoA');

      await entrar(null);

      expect(vm.rankingState.rankingPessoal.value, isEmpty);
      expect(vm.rankingState.erroPessoal.value, isNull);
      expect(vm.rankingState.carregandoPessoal.value, isFalse);
      expect(vm.rankingState.rankingGlobal.value.map((i) => i.pessoa.nome),
          ['Global1', 'Global2']);
    });

    test('resposta atrasada da conta A é descartada e B faz nova requisição', () async {
      final doA = vm.commands.carregarRankingPessoal(); // pendente
      await entrar(_b);

      final doB = vm.commands.carregarRankingPessoal();
      // B não reaproveitou a requisição de A (Command foi resetado).
      expect(facade.pessoal, hasLength(2));
      // Durante o carregamento de B não há dados de A.
      expect(vm.rankingState.rankingPessoal.value, isEmpty);
      expect(vm.rankingState.carregandoPessoal.value, isTrue);

      facade.pessoal[0].complete(Success(_ranking(['DoA']))); // chega tarde
      await doA;
      expect(vm.rankingState.rankingPessoal.value, isEmpty);
      expect(vm.rankingState.carregandoPessoal.value, isTrue);

      facade.pessoal[1].complete(Success(_ranking(['DoB'])));
      await doB;
      expect(vm.rankingState.rankingPessoal.value.single.pessoa.nome, 'DoB');
      expect(vm.rankingState.carregandoPessoal.value, isFalse);
    });

    test('falha ao carregar o ranking de B não exibe os dados de A', () async {
      final doA = vm.commands.carregarRankingPessoal();
      facade.pessoal.last.complete(Success(_ranking(['DoA'])));
      await doA;

      await entrar(_b);
      final doB = vm.commands.carregarRankingPessoal();
      facade.pessoal.last.complete(Error(RemoteFailure('Servidor indisponível.')));
      await doB;

      expect(vm.rankingState.rankingPessoal.value, isEmpty);
      expect(vm.rankingState.erroPessoal.value, 'Servidor indisponível.');
    });

    test('mesmo usuário (reemissão do stream) não limpa o ranking', () async {
      final doA = vm.commands.carregarRankingPessoal();
      facade.pessoal.last.complete(Success(_ranking(['DoA'])));
      await doA;

      await entrar(_a);
      expect(vm.rankingState.rankingPessoal.value.single.pessoa.nome, 'DoA');
    });
  });

  group('Avaliação e permissão', () {
    late _FakeAvaliacao facade;
    late AvaliacaoViewModel vm;

    setUp(() {
      facade = _FakeAvaliacao();
      vm = AvaliacaoViewModel(facade, auth);
    });

    test('logout remove permissão, avaliação existente e notas', () async {
      final carregando = vm.commands.carregar('p1');
      facade.verificar.last.complete(const Success(PermissaoAvaliacao.permitida));
      await pumpEventQueue();
      facade.consultar.last.complete(Success(_avaliacao('p1', 'uidA')));
      await carregando;
      expect(vm.avaliacaoState.avaliacaoAtual.value, isNotNull);

      await entrar(null);

      final st = vm.avaliacaoState;
      expect(st.pessoaId.value, isNull);
      expect(st.permissao.value, isNull);
      expect(st.avaliacaoAtual.value, isNull);
      expect(st.criterios.value, const CriteriosPopularidade());
      expect(st.isLoading.value, isFalse);
      expect(st.jaAvaliou.value, isFalse);
    });

    test('verificação atrasada de A não define a permissão de B', () async {
      final doA = vm.commands.carregar('p1'); // A é a própria p1 → autoavaliação
      await entrar(_b);

      final doB = vm.commands.carregar('p1');
      expect(facade.verificar, hasLength(2)); // B não reaproveitou a verificação de A

      facade.verificar[0].complete(const Success(PermissaoAvaliacao.autoavaliacao));
      await doA;
      expect(vm.avaliacaoState.permissao.value, isNull);
      expect(vm.avaliacaoState.isLoading.value, isTrue); // B ainda carregando

      facade.verificar[1].complete(const Success(PermissaoAvaliacao.permitida));
      await pumpEventQueue();
      facade.consultar.last.complete(const Success(null)); // B ainda não avaliou
      await doB;

      expect(vm.avaliacaoState.permissao.value, PermissaoAvaliacao.permitida);
      expect(vm.avaliacaoState.avaliacaoAtual.value, isNull);
      expect(vm.avaliacaoState.isLoading.value, isFalse);
    });

    test('avaliação existente de A que chega tarde não aparece para B', () async {
      final doA = vm.commands.carregar('p2');
      facade.verificar.last.complete(const Success(PermissaoAvaliacao.permitida));
      await pumpEventQueue(); // A agora aguarda a consulta da avaliação

      await entrar(_b);
      facade.consultar.last.complete(Success(_avaliacao('p2', 'uidA')));
      await doA;

      expect(vm.avaliacaoState.avaliacaoAtual.value, isNull);
      expect(vm.avaliacaoState.permissao.value, isNull);
    });
  });

  group('Pessoas', () {
    test('logout limpa a lista e descarta resposta atrasada', () async {
      final facade = _FakePessoa();
      final vm = PessoaViewModel(facade, auth);

      final primeira = vm.commands.carregarPessoas();
      facade.todas.last.complete(Success([_p('Ana')]));
      await primeira;
      expect(vm.pessoaState.pessoas.value, hasLength(1));

      final atrasada = vm.commands.carregarPessoas();
      await entrar(null);
      expect(vm.pessoaState.pessoas.value, isEmpty);

      facade.todas.last.complete(Success([_p('Ana'), _p('Bia')]));
      await atrasada;
      expect(vm.pessoaState.pessoas.value, isEmpty);
      expect(vm.pessoaState.isLoading.value, isFalse);
    });
  });

  group('Tela de Ranking', () {
    testWidgets('aba Pessoal após troca de conta com falha não mostra dados de A',
        (tester) async {
      final facade = _FakeRanking();
      final vm = RankingViewModel(facade, auth);
      injector.addInstance<RankingViewModel>(vm);
      injector.commit();

      // A carrega seu ranking pessoal.
      final doA = vm.commands.carregarRankingPessoal();
      facade.pessoal.last.complete(Success(_ranking(['NomeDoA'])));
      await doA;

      // Troca para B; a tela abre e o carregamento de B falha.
      await tester.runAsync(() => entrar(_b));
      await tester.pumpWidget(const MaterialApp(home: RankingView()));
      await tester.pump(); // dispara o carregamento pós-frame
      expect(find.text('NomeDoA'), findsNothing); // nem durante o carregamento

      facade.pessoal.last.complete(Error(RemoteFailure('Servidor indisponível.')));
      await tester.pumpAndSettle();

      expect(find.text('NomeDoA'), findsNothing);
      expect(find.textContaining('Servidor indisponível.'), findsOneWidget);
    });
  });
}
