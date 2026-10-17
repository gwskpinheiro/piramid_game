import 'dart:async';

import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/models/usuario_entity.dart';
import '../commands/auth_commands.dart';
import 'auth_commands_viewmodel.dart';
import 'auth_state_viewmodel.dart';

class AuthViewModel {
  late final AuthStateViewModel authState;
  late final AuthCommandsViewModel commands;
  final IAuthFacadeUseCases _facade;
  StreamSubscription<Usuario?>? _sub;

  AuthViewModel(IAuthFacadeUseCases facade) : _facade = facade {
    authState = AuthStateViewModel();
    commands = AuthCommandsViewModel(
      state: authState,
      entrarEmailCmd: EntrarComEmailCommand(facade),
      cadastrarCmd: CadastrarUsuarioCommand(facade),
      entrarGoogleCmd: EntrarComGoogleCommand(facade),
      sairCmd: SairCommand(facade),
    );
  }

  /// Passa a observar a sessão do Firebase. O Future completa quando o
  /// primeiro estado (sessão persistida ou nenhuma) é conhecido, para que
  /// o roteador já decida corretamente entre Home e Login.
  Future<void> iniciarMonitoramento() {
    if (_sub != null) return Future.value();
    final primeiroEvento = Completer<void>();
    _sub = _facade.observarUsuario(()).listen(
      (usuario) {
        authState.setUsuario(usuario);
        // Mantém o perfil em `usuarios/{uid}` atualizado (não bloqueia a UI;
        // uma falha aqui não impede o uso do app).
        if (usuario != null) _facade.registrarPerfil(());
        if (!primeiroEvento.isCompleted) primeiroEvento.complete();
      },
      onError: (_) {
        authState.setUsuario(null);
        if (!primeiroEvento.isCompleted) primeiroEvento.complete();
      },
    );
    return primeiroEvento.future;
  }
}
