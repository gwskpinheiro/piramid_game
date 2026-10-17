import '../../core/typedefs/types_defs.dart';
import '../models/usuario_entity.dart';
import '../usecases/auth_usecases_interfaces.dart';
import 'auth_facade_usecases_interface.dart';

final class AuthFacadeUseCasesImpl implements IAuthFacadeUseCases {
  final IObservarUsuarioUseCase _observar;
  final IEntrarComEmailUseCase _entrarEmail;
  final ICadastrarUsuarioUseCase _cadastrar;
  final IEntrarComGoogleUseCase _entrarGoogle;
  final ISairUseCase _sair;
  final IRegistrarPerfilUsuarioUseCase _registrarPerfil;

  AuthFacadeUseCasesImpl({
    required IObservarUsuarioUseCase observar,
    required IEntrarComEmailUseCase entrarEmail,
    required ICadastrarUsuarioUseCase cadastrar,
    required IEntrarComGoogleUseCase entrarGoogle,
    required ISairUseCase sair,
    required IRegistrarPerfilUsuarioUseCase registrarPerfil,
  })  : _observar = observar, _entrarEmail = entrarEmail, _cadastrar = cadastrar,
        _entrarGoogle = entrarGoogle, _sair = sair, _registrarPerfil = registrarPerfil;

  @override Stream<Usuario?> observarUsuario(NoParams params) => _observar(params);
  @override Future<UsuarioResult> entrarComEmail(CredenciaisParams params) => _entrarEmail(params);
  @override Future<UsuarioResult> cadastrarUsuario(CredenciaisParams params) => _cadastrar(params);
  @override Future<UsuarioResult> entrarComGoogle(NoParams params) => _entrarGoogle(params);
  @override Future<VoidResult> sair(NoParams params) => _sair(params);
  @override Future<VoidResult> registrarPerfil(NoParams params) => _registrarPerfil(params);
}
