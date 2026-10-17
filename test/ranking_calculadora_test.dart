import 'package:flutter_test/flutter_test.dart';

import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/data/repositories/auth_repository_interface.dart';
import 'package:piramid_game/data/repositories/avaliacao_repository_interface.dart';
import 'package:piramid_game/data/repositories/pessoa_repository_interface.dart';
import 'package:piramid_game/domain/models/avaliacao_entity.dart';
import 'package:piramid_game/domain/models/pessoa_entity.dart';
import 'package:piramid_game/domain/models/ranking_entity.dart';
import 'package:piramid_game/domain/models/usuario_entity.dart';
import 'package:piramid_game/domain/usecases/ranking_calculadora.dart';
import 'package:piramid_game/domain/usecases/ranking_usecases_impl.dart';
import 'package:piramid_game/presentation/widgets/pontuacao_format.dart';

Pessoa _p(String id, [String? nome]) => Pessoa(
      id: id, nome: nome ?? id, apelido: '', curso: Curso.tads, turmaAno: 2024,
      dataNascimento: DateTime(2000), criadoPor: 'x',
      createdAt: DateTime(2024), updatedAt: DateTime(2024),
    );

/// Critérios cuja soma é exatamente [total] (15 a 75).
CriteriosPopularidade _criterios(int total) {
  assert(total >= 15 && total <= 75);
  final notas = List.filled(15, 1);
  var resto = total - 15;
  for (var i = 0; i < 15 && resto > 0; i++) {
    final inc = resto > 4 ? 4 : resto;
    notas[i] += inc;
    resto -= inc;
  }
  return CriteriosPopularidade(
    resenha: notas[0], presencaVip: notas[1], aura: notas[2], modoParceiro: notas[3],
    carisma: notas[4], humorMilhoes: notas[5], energiaGrupo: notas[6],
    criatividadeCaotica: notas[7], modoAtleta: notas[8], talentopalco: notas[9],
    dripEscolar: notas[10], coracaoDorama: notas[11], queridinhoProf: notas[12],
    cerebroTurbo: notas[13], caosControlado: notas[14],
  );
}

Avaliacao _a(String pessoaId, String uid, int total, {DateTime? data}) => Avaliacao(
      id: Avaliacao.gerarId(pessoaId, uid), pessoaId: pessoaId, avaliadorUid: uid,
      criterios: _criterios(total), createdAt: DateTime(2026),
      dataAvaliacao: data ?? DateTime(2026),
    );

List<(String, int, num)> _resumo(List<ItemRanking> r) =>
    [for (final i in r) (i.pessoa.id, i.posicao, i.pontuacao)];

void main() {
  test('helper de critérios gera a soma pedida', () {
    expect(_criterios(15).nivelLenda, 15);
    expect(_criterios(58).nivelLenda, 58);
    expect(_criterios(75).nivelLenda, 75);
  });

  group('Ranking global', () {
    test('vazio quando não há avaliações', () {
      expect(RankingCalculadora.global(pessoas: [_p('ana')], avaliacoes: []), isEmpty);
      expect(RankingCalculadora.global(pessoas: [], avaliacoes: []), isEmpty);
    });

    test('média do exemplo do PDF: (60 + 70 + 65) / 3 = 65', () {
      final r = RankingCalculadora.global(pessoas: [_p('ana')], avaliacoes: [
        _a('ana', 'u1', 60), _a('ana', 'u2', 70), _a('ana', 'u3', 65),
      ]);
      expect(r.single.pontuacao, 65);
      expect(r.single.quantidadeAvaliacoes, 3);
      expect(r.single.posicao, 1);
    });

    test('média não inteira é preservada (ex.: 64,8)', () {
      // 5 avaliações somando 324 → 64,8
      final r = RankingCalculadora.global(pessoas: [_p('joao')], avaliacoes: [
        _a('joao', 'u1', 60), _a('joao', 'u2', 65), _a('joao', 'u3', 66),
        _a('joao', 'u4', 66), _a('joao', 'u5', 67),
      ]);
      expect(r.single.pontuacao, closeTo(64.8, 1e-9));
      expect(formatarPontuacao(r.single), '64,8 pts');
    });

    test('ordena da maior para a menor média e conta as avaliações', () {
      final r = RankingCalculadora.global(
        pessoas: [_p('ana'), _p('joao'), _p('maria')],
        avaliacoes: [
          _a('maria', 'u1', 54),
          _a('ana', 'u1', 70), _a('ana', 'u2', 66),
          _a('joao', 'u2', 58),
        ],
      );
      expect(_resumo(r), [('ana', 1, 68), ('joao', 2, 58), ('maria', 3, 54)]);
      expect(r.map((i) => i.quantidadeAvaliacoes), [2, 1, 1]);
    });

    test('empate compartilha a posição (1º, 1º, 3º)', () {
      final r = RankingCalculadora.global(
        pessoas: [_p('ana', 'Ana'), _p('bia', 'Bia'), _p('caio', 'Caio')],
        avaliacoes: [_a('bia', 'u1', 60), _a('ana', 'u1', 60), _a('caio', 'u1', 50)],
      );
      expect(_resumo(r), [('ana', 1, 60), ('bia', 1, 60), ('caio', 3, 50)]);
    });

    test('empate exato de médias com quantidades diferentes (60/1 = 120/2)', () {
      final r = RankingCalculadora.global(
        pessoas: [_p('ana'), _p('bia')],
        avaliacoes: [_a('ana', 'u1', 60), _a('bia', 'u1', 50), _a('bia', 'u2', 70)],
      );
      // Mesma média → mesma posição; desempate de ordem: mais avaliações primeiro.
      expect(_resumo(r), [('bia', 1, 60), ('ana', 1, 60)]);
    });

    test('médias muito próximas não são tratadas como empate', () {
      // 200/3 = 66,666… vs 67 → 67 vence e não empata
      final r = RankingCalculadora.global(
        pessoas: [_p('ana'), _p('bia')],
        avaliacoes: [
          _a('ana', 'u1', 66), _a('ana', 'u2', 67), _a('ana', 'u3', 67),
          _a('bia', 'u1', 67),
        ],
      );
      expect(_resumo(r).map((e) => (e.$1, e.$2)), [('bia', 1), ('ana', 2)]);
    });

    test('ignora avaliações órfãs (pessoa excluída)', () {
      final r = RankingCalculadora.global(
        pessoas: [_p('ana')],
        avaliacoes: [_a('ana', 'u1', 60), _a('excluida', 'u1', 75), _a('excluida', 'u2', 75)],
      );
      expect(_resumo(r), [('ana', 1, 60)]);
    });

    test('pessoas sem avaliações não entram no ranking', () {
      final r = RankingCalculadora.global(
        pessoas: [_p('ana'), _p('semNota')],
        avaliacoes: [_a('ana', 'u1', 40)],
      );
      expect(r.map((i) => i.pessoa.id), ['ana']);
    });

    test('duplicata do mesmo avaliador conta uma vez (a mais recente)', () {
      final r = RankingCalculadora.global(pessoas: [_p('ana')], avaliacoes: [
        _a('ana', 'u1', 20, data: DateTime(2026, 1, 1)),
        _a('ana', 'u1', 70, data: DateTime(2026, 2, 1)),
      ]);
      expect(r.single.quantidadeAvaliacoes, 1);
      expect(r.single.pontuacao, 70);
    });
  });

  group('Ranking pessoal', () {
    test('considera somente as avaliações do usuário autenticado', () {
      final r = RankingCalculadora.pessoal(
        pessoas: [_p('ana'), _p('joao'), _p('maria')],
        avaliacoes: [
          _a('ana', 'eu', 68), _a('joao', 'eu', 58), _a('maria', 'eu', 54),
          _a('maria', 'outro', 75), _a('joao', 'outro', 15),
        ],
        avaliadorUid: 'eu',
      );
      // Exemplo do PDF: 68, 58, 54 — avaliações de "outro" não interferem.
      expect(_resumo(r), [('ana', 1, 68), ('joao', 2, 58), ('maria', 3, 54)]);
      expect(r.every((i) => i.quantidadeAvaliacoes == 1), isTrue);
      expect(formatarPontuacao(r.first), '68 pts');
    });

    test('vazio quando o usuário não avaliou ninguém', () {
      final r = RankingCalculadora.pessoal(
        pessoas: [_p('ana')], avaliacoes: [_a('ana', 'outro', 60)], avaliadorUid: 'eu',
      );
      expect(r, isEmpty);
    });

    test('empate e órfã no ranking pessoal', () {
      final r = RankingCalculadora.pessoal(
        pessoas: [_p('ana', 'Ana'), _p('bia', 'Bia')],
        avaliacoes: [_a('bia', 'eu', 50), _a('ana', 'eu', 50), _a('excluida', 'eu', 75)],
        avaliadorUid: 'eu',
      );
      expect(_resumo(r), [('ana', 1, 50), ('bia', 1, 50)]);
    });
  });

  group('Use cases de ranking', () {
    late _FakePessoaRepo pessoas;
    late _FakeAvaliacaoRepo avaliacoes;
    late _FakeAuthRepo auth;

    setUp(() {
      pessoas = _FakePessoaRepo([_p('ana'), _p('joao')]);
      avaliacoes = _FakeAvaliacaoRepo([
        _a('ana', 'eu', 60), _a('joao', 'outro', 70), _a('ana', 'outro', 70),
      ]);
      auth = _FakeAuthRepo(const Usuario(uid: 'eu'));
    });

    test('pessoal busca apenas as avaliações do usuário logado', () async {
      final uc = CalcularRankingPessoalUseCaseImpl(
        authRepository: auth, pessoaRepository: pessoas, avaliacaoRepository: avaliacoes,
      );
      final r = (await uc(())).successValueOrNull!;
      expect(avaliacoes.consultouAvaliador, 'eu');
      expect(_resumo(r), [('ana', 1, 60)]);
    });

    test('global usa todas as avaliações', () async {
      final uc = CalcularRankingGlobalUseCaseImpl(
        pessoaRepository: pessoas, avaliacaoRepository: avaliacoes,
      );
      final r = (await uc(())).successValueOrNull!;
      expect(_resumo(r), [('joao', 1, 70), ('ana', 2, 65)]);
    });

    test('falha ao ler avaliações é propagada como Result de erro', () async {
      avaliacoes.falha = RemoteFailure('Servidor indisponível.');
      final uc = CalcularRankingGlobalUseCaseImpl(
        pessoaRepository: pessoas, avaliacaoRepository: avaliacoes,
      );
      final r = await uc(());
      expect(r.isFailure, isTrue);
      expect(r.failureValueOrNull!.msg, 'Servidor indisponível.');
    });

    test('pessoal sem usuário autenticado retorna erro', () async {
      final uc = CalcularRankingPessoalUseCaseImpl(
        authRepository: _FakeAuthRepo(null), pessoaRepository: pessoas,
        avaliacaoRepository: avaliacoes,
      );
      expect((await uc(())).isFailure, isTrue);
    });
  });
}

class _FakePessoaRepo implements IPessoaRepository {
  final List<Pessoa> lista;
  _FakePessoaRepo(this.lista);
  @override
  Future<ListPessoaResult> obterTodasPessoas() async => Success(lista);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAvaliacaoRepo implements IAvaliacaoRepository {
  final List<Avaliacao> lista;
  Failure? falha;
  String? consultouAvaliador;
  _FakeAvaliacaoRepo(this.lista);

  @override
  Future<ListAvaliacaoResult> obterTodasAvaliacoes() async =>
      falha != null ? Error(falha!) : Success(lista);
  @override
  Future<ListAvaliacaoResult> obterAvaliacoesDoAvaliador(String uid) async {
    consultouAvaliador = uid;
    return falha != null
        ? Error(falha!)
        : Success(lista.where((a) => a.avaliadorUid == uid).toList());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepo implements IAuthRepository {
  @override
  final Usuario? usuarioAtual;
  _FakeAuthRepo(this.usuarioAtual);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
