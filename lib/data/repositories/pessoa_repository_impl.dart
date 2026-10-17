import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';
import '../services/pessoa_remote_storage_interface.dart';
import 'pessoa_repository_interface.dart';

final class PessoaRepositoryImpl implements IPessoaRepository {
  final IPessoaRemoteStorage _remoteStorage;

  PessoaRepositoryImpl({required IPessoaRemoteStorage remoteStorage})
      : _remoteStorage = remoteStorage;

  @override
  Future<PessoaResult> salvarPessoa(Pessoa pessoa) => _remoteStorage.salvarPessoa(pessoa);
  @override
  Future<ListPessoaResult> obterTodasPessoas() => _remoteStorage.obterTodasPessoas();
  @override
  Future<PessoaResult> obterPessoaPorId(String id) => _remoteStorage.obterPessoaPorId(id);
  @override
  Future<PessoaResult> atualizarPessoa(Pessoa pessoa) => _remoteStorage.atualizarPessoa(pessoa);
  @override
  Future<VoidResult> deletarPessoa(String id) => _remoteStorage.deletarPessoa(id);
}
