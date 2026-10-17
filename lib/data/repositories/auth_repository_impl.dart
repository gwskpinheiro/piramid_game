import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';
import '../services/auth_service_interface.dart';
import 'auth_repository_interface.dart';

final class AuthRepositoryImpl implements IAuthRepository {
  final IAuthService _service;

  AuthRepositoryImpl({required IAuthService service}) : _service = service;

  @override
  Stream<Usuario?> observarUsuario() => _service.observarUsuario();
  @override
  Usuario? get usuarioAtual => _service.usuarioAtual;
  @override
  Future<UsuarioResult> entrarComEmail(String email, String senha) =>
      _service.entrarComEmail(email, senha);
  @override
  Future<UsuarioResult> cadastrarComEmail(String email, String senha) =>
      _service.cadastrarComEmail(email, senha);
  @override
  Future<UsuarioResult> entrarComGoogle() => _service.entrarComGoogle();
  @override
  Future<VoidResult> sair() => _service.sair();
}
