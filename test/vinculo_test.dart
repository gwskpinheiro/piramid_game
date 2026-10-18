import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:piramid_game/core/di/dependency_injection.dart';
import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/routes/app_routes.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/data/repositories/auth_repository_interface.dart';
import 'package:piramid_game/data/repositories/pessoa_repository_interface.dart';
import 'package:piramid_game/data/repositories/usuario_repository_interface.dart';
import 'package:piramid_game/data/repositories/vinculo_repository_interface.dart';
import 'package:piramid_game/domain/facades/auth_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/vinculo_facade_usecases_interface.dart';
import 'package:piramid_game/domain/models/pessoa_entity.dart';
import 'package:piramid_game/domain/models/usuario_entity.dart';
import 'package:piramid_game/domain/usecases/vinculo_usecases_impl.dart';
import 'package:piramid_game/presentation/controllers/auth_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/vinculo_viewmodel.dart';
import 'package:piramid_game/presentation/views/auth/identificacao_view.dart';

Pessoa _p(String id, [String? nome]) => Pessoa(
      id: id, nome: nome ?? id, apelido: '', curso: Curso.tads, turmaAno: 2024,
      dataNascimento: DateTime(2000), criadoPor: 'x',
      createdAt: DateTime(2024), updatedAt: DateTime(2024),
    );

// ── Fakes de repositório (use cases) ──────────────────────────────────────
class _Auth implements IAuthRepository {
  @override
  final Usuario? usuarioAtual;
  _Auth(this.usuarioAtual);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Usuarios implements IUsuarioRepository {
  String? vinculoAtual;
  _Usuarios([this.vinculoAtual]);
  @override
  Future<VinculoResult> obterPessoaVinculada(String uid) async => Success(vinculoAtual);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Pessoas implements IPessoaRepository {
  @override
  Future<ListPessoaResult> obterTodasPessoas() async => Success([_p('pA'), _p('pB'), _p('pC')]);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Vinculos implements IVinculoRepository {
  final chamadas = <String>[];
  Pessoa? cadastrada;
  @override
  Future<IdsResult> obterPessoasVinculadas() async => const Success({'pB'});
  @override
  Future<VoidResult> vincularPessoaExistente(String uid, String pessoaId) async {
    chamadas.add('$uid→$pessoaId');
    return const Success(null);
  }

  @override
  Future<PessoaResult> cadastrarPerfilEVincular(String uid, Pessoa pessoa) async {
    cadastrada = pessoa;
    return Success(pessoa.copyWith(id: 'novo'));
  }
}

// ── Fakes de facade (ViewModel e tela) ────────────────────────────────────
class _FakeAuthFacade implements IAuthFacadeUseCases {
  final controller = StreamController<Usuario?>.broadcast();
  int saidas = 0;
  @override
  Stream<Usuario?> observarUsuario(NoParams params) => controller.stream;
  @override
  Future<VoidResult> registrarPerfil(NoParams params) async => const Success(null);
  @override
  Future<VoidResult> sair(NoParams params) async {
    saidas++;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeVinculoFacade implements IVinculoFacadeUseCases {
  String? vinculo;
  int verificacoes = 0;
  int carregamentos = 0;
  Failure? falhaAoVincular;
  final vinculadas = <String>[];

  @override
  Future<VinculoResult> obterVinculo(NoParams params) async {
    verificacoes++;
    return Success(vinculo);
  }

  @override
  Future<ListPessoaResult> obterPessoasDisponiveis(NoParams params) async {
    carregamentos++;
    return Success([_p('pA', 'Ana Livre'), _p('pC', 'Caio Livre')]);
  }

  @override
  Future<VinculoResult> vincularPessoaExistente(PessoaIdParams params) async {
    if (falhaAoVincular != null) return Error(falhaAoVincular!);
    vinculadas.add(params.id);
    vinculo = params.id;
    return Success(params.id);
  }

  @override
  Future<PessoaResult> cadastrarPerfilEVincular(PessoaParams params) async {
    vinculo = 'novo';
    return Success(params.pessoa.copyWith(id: 'novo'));
  }
}

const _u1 = Usuario(uid: 'u1');
const _u2 = Usuario(uid: 'u2');

void main() {
  group('Roteamento (Login → Identificação → Home)', () {
    String? r(String loc, {required bool logado, bool? vinculo}) =>
        AppRouter.decidirRedirect(loc: loc, logado: logado, possuiVinculo: vinculo);

    test('splash nunca é redirecionada', () {
      expect(r('/', logado: false), isNull);
      expect(r('/', logado: true, vinculo: false), isNull);
    });
    test('sem login → login (rotas públicas liberadas)', () {
      expect(r('/home', logado: false), '/login');
      expect(r('/identificacao', logado: false), '/login');
      expect(r('/login', logado: false), isNull);
      expect(r('/cadastro', logado: false), isNull);
    });
    test('logado sem vínculo (ou verificando) → identificação obrigatória', () {
      for (final v in [false, null]) {
        expect(r('/home', logado: true, vinculo: v), '/identificacao');
        expect(r('/ranking', logado: true, vinculo: v), '/identificacao');
        expect(r('/avaliar/p1', logado: true, vinculo: v), '/identificacao');
        expect(r('/login', logado: true, vinculo: v), '/identificacao');
        expect(r('/identificacao', logado: true, vinculo: v), isNull);
      }
    });
    test('logado com vínculo → acesso normal e sem repetir a identificação', () {
      expect(r('/home', logado: true, vinculo: true), isNull);
      expect(r('/ranking', logado: true, vinculo: true), isNull);
      expect(r('/identificacao', logado: true, vinculo: true), '/home');
      expect(r('/login', logado: true, vinculo: true), '/home');
    });
  });

  group('Use cases de vínculo', () {
    test('perfis disponíveis excluem pessoas já vinculadas', () async {
      final uc = ObterPessoasDisponiveisUseCaseImpl(
          pessoaRepository: _Pessoas(), vinculoRepository: _Vinculos());
      final lista = (await uc(())).successValueOrNull!;
      expect(lista.map((p) => p.id), ['pA', 'pC']);
    });

    test('vincula pessoa existente usando o uid da conta autenticada', () async {
      final repo = _Vinculos();
      final uc = VincularPessoaExistenteUseCaseImpl(
          authRepository: _Auth(_u1), usuarioRepository: _Usuarios(), vinculoRepository: repo);
      final r = await uc((id: 'pA'));
      expect(r.successValueOrNull, 'pA');
      expect(repo.chamadas, ['u1→pA']);
    });

    test('conta já vinculada não pode trocar de perfil', () async {
      final repo = _Vinculos();
      final uc = VincularPessoaExistenteUseCaseImpl(
          authRepository: _Auth(_u1), usuarioRepository: _Usuarios('pA'), vinculoRepository: repo);
      final r = await uc((id: 'pC'));
      expect(r.isFailure, isTrue);
      expect(r.failureValueOrNull!.msg, contains('não pode ser alterado'));
      expect(repo.chamadas, isEmpty);
    });

    test('sem login não vincula', () async {
      final uc = VincularPessoaExistenteUseCaseImpl(
          authRepository: _Auth(null), usuarioRepository: _Usuarios(), vinculoRepository: _Vinculos());
      expect((await uc((id: 'pA'))).isFailure, isTrue);
    });

    test('cadastro do próprio perfil valida os dados e registra criadoPor = uid', () async {
      final repo = _Vinculos();
      final uc = CadastrarPerfilEVincularUseCaseImpl(
          authRepository: _Auth(_u1), usuarioRepository: _Usuarios(), vinculoRepository: repo);

      final invalido = await uc((pessoa: _p('', '   ')));
      expect(invalido.failureValueOrNull, isA<InputFailure>());
      expect(repo.cadastrada, isNull);

      final ok = await uc((pessoa: _p('', '  Gustavo  ')));
      expect(ok.isSuccess, isTrue);
      expect(repo.cadastrada!.criadoPor, 'u1');
      expect(repo.cadastrada!.nome, 'Gustavo');
    });

    test('cadastro do próprio perfil é recusado se a conta já tem vínculo', () async {
      final repo = _Vinculos();
      final uc = CadastrarPerfilEVincularUseCaseImpl(
          authRepository: _Auth(_u1), usuarioRepository: _Usuarios('pA'), vinculoRepository: repo);
      expect((await uc((pessoa: _p('', 'Outro')))).isFailure, isTrue);
      expect(repo.cadastrada, isNull);
    });
  });

  group('VinculoViewModel', () {
    late _FakeAuthFacade authFacade;
    late AuthViewModel auth;
    late _FakeVinculoFacade facade;
    late VinculoViewModel vm;

    Future<void> entrar(Usuario? u) async {
      authFacade.controller.add(u);
      await pumpEventQueue();
    }

    setUp(() async {
      authFacade = _FakeAuthFacade();
      auth = AuthViewModel(authFacade);
      facade = _FakeVinculoFacade();
      vm = VinculoViewModel(facade, auth);
      final pronto = auth.iniciarMonitoramento();
      authFacade.controller.add(_u1);
      await pronto;
      await pumpEventQueue();
    });

    test('login dispara a verificação: sem vínculo → false', () {
      expect(facade.verificacoes, 1);
      expect(vm.possuiVinculo.value, isFalse);
    });

    test('vincular com sucesso libera o acesso (possuiVinculo = true)', () async {
      expect(await vm.vincularPessoa('pA'), isTrue);
      expect(vm.possuiVinculo.value, isTrue);
      expect(facade.vinculadas, ['pA']);
    });

    test('recusa (perfil vinculado por outra conta) mostra mensagem e recarrega', () async {
      facade.falhaAoVincular = RemoteFailure('Este perfil acabou de ser vinculado a outra conta.');
      final carregamentosAntes = facade.carregamentos;
      expect(await vm.vincularPessoa('pA'), isFalse);
      await pumpEventQueue();
      expect(vm.possuiVinculo.value, isFalse);
      expect(vm.mensagem.value, contains('outra conta'));
      expect(facade.carregamentos, carregamentosAntes + 1);
    });

    test('logout limpa; outra conta é verificada de novo', () async {
      await vm.vincularPessoa('pA');
      await entrar(null);
      expect(vm.possuiVinculo.value, isNull);
      expect(vm.pessoasDisponiveis.value, isEmpty);

      facade.vinculo = null; // a conta u2 ainda não tem vínculo
      await entrar(_u2);
      expect(vm.possuiVinculo.value, isFalse);
    });
  });

  group('Tela de identificação', () {
    testWidgets('lista perfis livres e vincula após confirmação', (tester) async {
      final authFacade = _FakeAuthFacade();
      final auth = AuthViewModel(authFacade);
      final facade = _FakeVinculoFacade();
      final vm = VinculoViewModel(facade, auth);
      injector.addInstance<AuthViewModel>(auth);
      injector.addInstance<VinculoViewModel>(vm);
      injector.commit();
      await tester.runAsync(() async {
        final pronto = auth.iniciarMonitoramento();
        authFacade.controller.add(_u1);
        await pronto;
        await vm.verificarVinculo();
      });

      await tester.pumpWidget(const MaterialApp(home: IdentificacaoView()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ana Livre'), findsOneWidget);
      expect(find.text('Caio Livre'), findsOneWidget);

      await tester.tap(find.text('Ana Livre'));
      await tester.pumpAndSettle();
      expect(find.textContaining('vínculo é definitivo'), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(facade.vinculadas, ['pA']);
      expect(vm.possuiVinculo.value, isTrue);
    });
  });
}
