import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../services/avaliacao_remote_storage_interface.dart';
import 'avaliacao_repository_interface.dart';

final class AvaliacaoRepositoryImpl implements IAvaliacaoRepository {
  final IAvaliacaoRemoteStorage _remoteStorage;

  AvaliacaoRepositoryImpl({required IAvaliacaoRemoteStorage remoteStorage})
      : _remoteStorage = remoteStorage;

  @override
  Future<AvaliacaoResult> registrarAvaliacao(Avaliacao avaliacao) =>
      _remoteStorage.registrarAvaliacao(avaliacao);
  @override
  Future<AvaliacaoResult> alterarAvaliacao(Avaliacao avaliacao) =>
      _remoteStorage.alterarAvaliacao(avaliacao);
  @override
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(String pessoaId, String avaliadorUid) =>
      _remoteStorage.consultarAvaliacao(pessoaId, avaliadorUid);
  @override
  Future<ListAvaliacaoResult> obterAvaliacoesDoAvaliador(String avaliadorUid) =>
      _remoteStorage.obterAvaliacoesDoAvaliador(avaliadorUid);
  @override
  Future<ListAvaliacaoResult> obterTodasAvaliacoes() => _remoteStorage.obterTodasAvaliacoes();
}
