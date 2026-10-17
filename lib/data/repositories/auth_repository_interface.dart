import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';

abstract interface class IAuthRepository {
  Stream<Usuario?> observarUsuario();
  Usuario? get usuarioAtual;
  Future<UsuarioResult> entrarComEmail(String email, String senha);
  Future<UsuarioResult> cadastrarComEmail(String email, String senha);
  Future<UsuarioResult> entrarComGoogle();
  Future<VoidResult> sair();
}
