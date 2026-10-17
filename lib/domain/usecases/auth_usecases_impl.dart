import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/usuario_repository_interface.dart';
import '../models/usuario_entity.dart';
import 'auth_usecases_interfaces.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Valida as credenciais; retorna a mensagem de erro ou null se válidas.
String? _validarCredenciais(CredenciaisParams params, {bool cadastro = false}) {
  final email = params.email.trim();
  if (email.isEmpty) return 'Informe o e-mail.';
  if (!_emailRegex.hasMatch(email)) return 'O e-mail informado é inválido.';
  if (params.senha.isEmpty) return 'Informe a senha.';
  if (cadastro && params.senha.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres.';
  }
  return null;
}

final class ObservarUsuarioUseCaseImpl implements IObservarUsuarioUseCase {
  final IAuthRepository _repository;
  ObservarUsuarioUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Stream<Usuario?> call(NoParams params) => _repository.observarUsuario();
}

final class EntrarComEmailUseCaseImpl implements IEntrarComEmailUseCase {
  final IAuthRepository _repository;
  EntrarComEmailUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(CredenciaisParams params) async {
    final erro = _validarCredenciais(params);
    if (erro != null) return r.Error(InputFailure(erro));
    return _repository.entrarComEmail(params.email.trim(), params.senha);
  }
}

final class CadastrarUsuarioUseCaseImpl implements ICadastrarUsuarioUseCase {
  final IAuthRepository _repository;
  CadastrarUsuarioUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(CredenciaisParams params) async {
    final erro = _validarCredenciais(params, cadastro: true);
    if (erro != null) return r.Error(InputFailure(erro));
    return _repository.cadastrarComEmail(params.email.trim(), params.senha);
  }
}

final class EntrarComGoogleUseCaseImpl implements IEntrarComGoogleUseCase {
  final IAuthRepository _repository;
  EntrarComGoogleUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(NoParams params) => _repository.entrarComGoogle();
}

final class SairUseCaseImpl implements ISairUseCase {
  final IAuthRepository _repository;
  SairUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(NoParams params) => _repository.sair();
}

final class RegistrarPerfilUsuarioUseCaseImpl implements IRegistrarPerfilUsuarioUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  RegistrarPerfilUsuarioUseCaseImpl({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository, _usuarioRepository = usuarioRepository;

  @override
  Future<VoidResult> call(NoParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return r.Error(AuthFailure('Nenhum usuário autenticado.'));
    return _usuarioRepository.salvarPerfil(usuario);
  }
}
