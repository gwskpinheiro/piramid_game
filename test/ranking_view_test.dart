import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:piramid_game/core/di/dependency_injection.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/domain/facades/auth_facade_usecases_interface.dart';
import 'package:piramid_game/domain/facades/ranking_facade_usecases_interface.dart';
import 'package:piramid_game/domain/models/pessoa_entity.dart';
import 'package:piramid_game/domain/models/ranking_entity.dart';
import 'package:piramid_game/presentation/controllers/auth_viewmodel.dart';
import 'package:piramid_game/presentation/controllers/ranking_viewmodel.dart';
import 'package:piramid_game/presentation/views/ranking/ranking_view.dart';

Pessoa _p(String nome) => Pessoa(
      id: nome, nome: nome, apelido: '', curso: Curso.info, turmaAno: 2024,
      dataNascimento: DateTime(2000), criadoPor: 'x',
      createdAt: DateTime(2024), updatedAt: DateTime(2024),
    );

class _FakeRankingFacade implements IRankingFacadeUseCases {
  @override
  Future<RankingResult> gerarRankingPessoal(NoParams params) async => const Success([]);

  @override
  Future<RankingResult> gerarRankingGlobal(NoParams params) async => Success([
        ItemRanking(pessoa: _p('Ana'), posicao: 1, somaPontuacoes: 342, quantidadeAvaliacoes: 5),
        ItemRanking(pessoa: _p('Joao'), posicao: 2, somaPontuacoes: 58, quantidadeAvaliacoes: 1),
        ItemRanking(pessoa: _p('Maria'), posicao: 3, somaPontuacoes: 108, quantidadeAvaliacoes: 2),
        ItemRanking(pessoa: _p('Pedro'), posicao: 4, somaPontuacoes: 40, quantidadeAvaliacoes: 1),
      ]);
}

class _SemAuthFacade implements IAuthFacadeUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    injector.addInstance<RankingViewModel>(
        RankingViewModel(_FakeRankingFacade(), AuthViewModel(_SemAuthFacade())));
    injector.commit();
  });

  testWidgets('aba Global exibe pódio, média e quantidade de avaliações', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RankingView(abaInicial: 1)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('68,4 pts'), findsOneWidget); // 342 / 5
    expect(find.text('5 avaliações'), findsOneWidget);
    expect(find.text('1 avaliação'), findsWidgets);
    expect(find.text('Pedro'), findsOneWidget); // "Demais posições"
    expect(find.text('4°'), findsOneWidget);
  });

  testWidgets('aba Pessoal vazia mostra orientação', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RankingView()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Você ainda não avaliou ninguém'), findsOneWidget);
  });
}
