import '../../core/typedefs/types_defs.dart';

abstract interface class IPessoaFacadeUseCases {
  Future<PessoaResult> cadastrarPessoa(PessoaParams params);
  Future<ListPessoaResult> obterTodasPessoas(NoParams params);
  Future<PessoaResult> obterPessoaPorId(PessoaIdParams params);
  Future<PessoaResult> atualizarPessoa(PessoaParams params);
  Future<VoidResult> deletarPessoa(PessoaIdParams params);
}
