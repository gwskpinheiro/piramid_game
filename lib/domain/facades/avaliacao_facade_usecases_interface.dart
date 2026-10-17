import '../../core/typedefs/types_defs.dart';

abstract interface class IAvaliacaoFacadeUseCases {
  Future<PermissaoAvaliacaoResult> verificarAutoavaliacao(PessoaIdParams params);
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(PessoaIdParams params);
  Future<AvaliacaoResult> avaliar(AvaliarParams params);
  Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params);
}
