import '../models/avaliacao_entity.dart';
import '../models/pessoa_entity.dart';
import '../models/ranking_entity.dart';

/// Regras puras de cálculo dos rankings (sem acesso a dados).
///
/// - Avaliações de pessoas que não existem mais (órfãs) são ignoradas.
/// - Ordenação: maior pontuação primeiro; em empate, mais avaliações
///   primeiro e, por fim, nome em ordem alfabética.
/// - Pontuações iguais compartilham a mesma posição (ex.: 1º, 1º, 3º).
abstract final class RankingCalculadora {
  /// Ranking pessoal: somente as avaliações feitas por [avaliadorUid].
  static List<ItemRanking> pessoal({
    required List<Pessoa> pessoas,
    required List<Avaliacao> avaliacoes,
    required String avaliadorUid,
  }) {
    final doUsuario = avaliacoes.where((a) => a.avaliadorUid == avaliadorUid).toList();
    return _calcular(pessoas, doUsuario);
  }

  /// Ranking global: média das avaliações recebidas de todos os usuários.
  static List<ItemRanking> global({
    required List<Pessoa> pessoas,
    required List<Avaliacao> avaliacoes,
  }) =>
      _calcular(pessoas, avaliacoes);

  static List<ItemRanking> _calcular(List<Pessoa> pessoas, List<Avaliacao> avaliacoes) {
    final pessoasPorId = {for (final p in pessoas) p.id: p};

    // Uma avaliação por (pessoa, avaliador): o id determinístico já garante
    // isso no Firestore; aqui mantemos só a mais recente por segurança.
    final unicas = <String, Avaliacao>{};
    for (final a in avaliacoes) {
      if (!pessoasPorId.containsKey(a.pessoaId)) continue; // órfã
      final chave = Avaliacao.gerarId(a.pessoaId, a.avaliadorUid);
      final atual = unicas[chave];
      if (atual == null || a.dataAvaliacao.isAfter(atual.dataAvaliacao)) unicas[chave] = a;
    }

    final soma = <String, int>{};
    final quantidade = <String, int>{};
    for (final a in unicas.values) {
      soma[a.pessoaId] = (soma[a.pessoaId] ?? 0) + a.nivelLenda;
      quantidade[a.pessoaId] = (quantidade[a.pessoaId] ?? 0) + 1;
    }

    final linhas = [
      for (final id in soma.keys)
        (pessoa: pessoasPorId[id]!, soma: soma[id]!, qtd: quantidade[id]!),
    ];

    linhas.sort((a, b) {
      final pontos = _compararMedia(b.soma, b.qtd, a.soma, a.qtd);
      if (pontos != 0) return pontos;
      final qtd = b.qtd.compareTo(a.qtd);
      if (qtd != 0) return qtd;
      return a.pessoa.nome.toLowerCase().compareTo(b.pessoa.nome.toLowerCase());
    });

    final resultado = <ItemRanking>[];
    for (var i = 0; i < linhas.length; i++) {
      final l = linhas[i];
      final empatado = i > 0 &&
          _compararMedia(l.soma, l.qtd, linhas[i - 1].soma, linhas[i - 1].qtd) == 0;
      resultado.add(ItemRanking(
        pessoa: l.pessoa,
        posicao: empatado ? resultado[i - 1].posicao : i + 1,
        somaPontuacoes: l.soma,
        quantidadeAvaliacoes: l.qtd,
      ));
    }
    return resultado;
  }

  /// Compara somaA/qtdA com somaB/qtdB de forma exata (multiplicação cruzada).
  static int _compararMedia(int somaA, int qtdA, int somaB, int qtdB) =>
      (somaA * qtdB).compareTo(somaB * qtdA);
}
