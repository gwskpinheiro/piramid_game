import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';
import '../services/vinculo_remote_storage_interface.dart';
import 'vinculo_repository_interface.dart';

final class VinculoRepositoryImpl implements IVinculoRepository {
  final IVinculoRemoteStorage _remoteStorage;

  VinculoRepositoryImpl({required IVinculoRemoteStorage remoteStorage})
      : _remoteStorage = remoteStorage;

  @override
  Future<IdsResult> obterPessoasVinculadas() => _remoteStorage.obterPessoasVinculadas();
  @override
  Future<VoidResult> vincularPessoaExistente(String uid, String pessoaId) =>
      _remoteStorage.vincularPessoaExistente(uid, pessoaId);
  @override
  Future<PessoaResult> cadastrarPerfilEVincular(String uid, Pessoa pessoa) =>
      _remoteStorage.cadastrarPerfilEVincular(uid, pessoa);
}
