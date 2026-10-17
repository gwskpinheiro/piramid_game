import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';

abstract interface class IUsuarioRemoteStorage {
  /// Grava/atualiza o perfil (nome, email, foto, provider) em `usuarios/{uid}`.
  /// Nunca envia o campo `pessoaId`, que é exclusivo do administrador.
  Future<VoidResult> salvarPerfil(Usuario usuario);

  /// Retorna o `pessoaId` vinculado ao usuário pelo administrador, ou null.
  Future<VinculoResult> obterPessoaVinculada(String uid);
}
