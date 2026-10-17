import 'package:equatable/equatable.dart';

import 'pessoa_entity.dart';

/// Uma linha de ranking (pessoal ou global).
///
/// A pontuação é guardada como soma + quantidade para que médias e empates
/// sejam comparados de forma exata, sem erros de arredondamento.
class ItemRanking extends Equatable {
  final Pessoa pessoa;
  /// Posição no ranking (1 = topo). Pontuações iguais compartilham a posição.
  final int posicao;
  final int somaPontuacoes;
  /// Quantidade de avaliações consideradas (no ranking pessoal é sempre 1).
  final int quantidadeAvaliacoes;

  const ItemRanking({
    required this.pessoa,
    required this.posicao,
    required this.somaPontuacoes,
    required this.quantidadeAvaliacoes,
  });

  /// Nível Lenda: pontuação da avaliação (pessoal) ou média recebida (global).
  double get pontuacao => somaPontuacoes / quantidadeAvaliacoes;

  @override
  List<Object?> get props => [pessoa, posicao, somaPontuacoes, quantidadeAvaliacoes];
}
