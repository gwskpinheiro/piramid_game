import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';

abstract interface class IAvaliacaoRepository {
  Future<AvaliacaoResult> registrarAvaliacao(Avaliacao avaliacao);
  Future<AvaliacaoResult> alterarAvaliacao(Avaliacao avaliacao);
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(String pessoaId, String avaliadorUid);
  /// Avaliações feitas por [avaliadorUid] (ranking pessoal).
  Future<ListAvaliacaoResult> obterAvaliacoesDoAvaliador(String avaliadorUid);
  /// Avaliações de todos os usuários (ranking global).
  Future<ListAvaliacaoResult> obterTodasAvaliacoes();
}
