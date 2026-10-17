import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';

abstract interface class IUsuarioRepository {
  Future<VoidResult> salvarPerfil(Usuario usuario);
  Future<VinculoResult> obterPessoaVinculada(String uid);
}
