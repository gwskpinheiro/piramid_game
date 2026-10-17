import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/models/usuario_entity.dart';

final class EntrarComEmailCommand extends ParameterizedCommand<Usuario, Failure, CredenciaisParams> {
  final IAuthFacadeUseCases _facade;
  EntrarComEmailCommand(this._facade);
  @override
  Future<UsuarioResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.entrarComEmail(parameter!);
  }
}

final class CadastrarUsuarioCommand extends ParameterizedCommand<Usuario, Failure, CredenciaisParams> {
  final IAuthFacadeUseCases _facade;
  CadastrarUsuarioCommand(this._facade);
  @override
  Future<UsuarioResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.cadastrarUsuario(parameter!);
  }
}

final class EntrarComGoogleCommand extends ParameterizedCommand<Usuario, Failure, NoParams> {
  final IAuthFacadeUseCases _facade;
  EntrarComGoogleCommand(this._facade);
  @override
  Future<UsuarioResult> execute() => _facade.entrarComGoogle(());
}

final class SairCommand extends ParameterizedCommand<void, Failure, NoParams> {
  final IAuthFacadeUseCases _facade;
  SairCommand(this._facade);
  @override
  Future<VoidResult> execute() => _facade.sair(());
}
