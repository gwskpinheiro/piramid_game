import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/ranking_entity.dart';

class RankingStateViewModel {
  final rankingPessoal = signal<List<ItemRanking>>([]);
  final rankingGlobal = signal<List<ItemRanking>>([]);
  final carregandoPessoal = signal<bool>(false);
  final carregandoGlobal = signal<bool>(false);
  final erroPessoal = signal<String?>(null);
  final erroGlobal = signal<String?>(null);

  late final top3Global = computed<List<ItemRanking>>(
      () => rankingGlobal.value.take(3).toList());

  void limparPessoal() {
    rankingPessoal.value = [];
    erroPessoal.value = null;
    carregandoPessoal.value = false;
  }
}
