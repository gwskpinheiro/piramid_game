import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';

/// Vínculo entre conta autenticada e pessoa cadastrada (`vinculos/{pessoaId}`).
abstract interface class IVinculoRemoteStorage {
  /// IDs das pessoas que já possuem conta vinculada (nunca expõe UIDs).
  Future<IdsResult> obterPessoasVinculadas();

  /// Vincula [uid] a uma pessoa existente, de forma atômica.
  Future<VoidResult> vincularPessoaExistente(String uid, String pessoaId);

  /// Cadastra o próprio perfil e o vincula a [uid], de forma atômica.
  Future<PessoaResult> cadastrarPerfilEVincular(String uid, Pessoa pessoa);
}
