import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';

abstract interface class IAuthService {
  /// Emite o usuário atual sempre que o estado de autenticação muda
  /// (o primeiro evento reflete a sessão persistida, se houver).
  Stream<Usuario?> observarUsuario();
  /// Usuário autenticado no momento (null se não houver sessão).
  Usuario? get usuarioAtual;
  Future<UsuarioResult> entrarComEmail(String email, String senha);
  Future<UsuarioResult> cadastrarComEmail(String email, String senha);
  Future<UsuarioResult> entrarComGoogle();
  Future<VoidResult> sair();
}
