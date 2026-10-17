import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';

abstract interface class IPessoaRemoteStorage {
  Future<PessoaResult> salvarPessoa(Pessoa pessoa);
  Future<ListPessoaResult> obterTodasPessoas();
  Future<PessoaResult> obterPessoaPorId(String id);
  Future<PessoaResult> atualizarPessoa(Pessoa pessoa);
  Future<VoidResult> deletarPessoa(String id);
}
