import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';

abstract interface class IVinculoRepository {
  Future<IdsResult> obterPessoasVinculadas();
  Future<VoidResult> vincularPessoaExistente(String uid, String pessoaId);
  Future<PessoaResult> cadastrarPerfilEVincular(String uid, Pessoa pessoa);
}
