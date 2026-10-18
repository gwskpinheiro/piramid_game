import '../../core/typedefs/types_defs.dart';

abstract interface class IVinculoFacadeUseCases {
  Future<VinculoResult> obterVinculo(NoParams params);
  Future<ListPessoaResult> obterPessoasDisponiveis(NoParams params);
  Future<VinculoResult> vincularPessoaExistente(PessoaIdParams params);
  Future<PessoaResult> cadastrarPerfilEVincular(PessoaParams params);
}
