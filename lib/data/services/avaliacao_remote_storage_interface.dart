import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';

abstract interface class IAvaliacaoRemoteStorage {
  Future<AvaliacaoResult> registrarAvaliacao(Avaliacao avaliacao);
  Future<AvaliacaoResult> alterarAvaliacao(Avaliacao avaliacao);
  /// Avaliação de [pessoaId] feita por [avaliadorUid], ou null se não existir.
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(String pessoaId, String avaliadorUid);
  /// Avaliações feitas por [avaliadorUid] (ranking pessoal).
  Future<ListAvaliacaoResult> obterAvaliacoesDoAvaliador(String avaliadorUid);
  /// Avaliações de todos os usuários (ranking global).
  Future<ListAvaliacaoResult> obterTodasAvaliacoes();
}
