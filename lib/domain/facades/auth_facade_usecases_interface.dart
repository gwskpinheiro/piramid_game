import '../../core/typedefs/types_defs.dart';
import '../models/usuario_entity.dart';

abstract interface class IAuthFacadeUseCases {
  Stream<Usuario?> observarUsuario(NoParams params);
  Future<UsuarioResult> entrarComEmail(CredenciaisParams params);
  Future<UsuarioResult> cadastrarUsuario(CredenciaisParams params);
  Future<UsuarioResult> entrarComGoogle(NoParams params);
  Future<VoidResult> sair(NoParams params);
  Future<VoidResult> registrarPerfil(NoParams params);
}
