import '../../core/typedefs/types_defs.dart';
import '../commands/auth_commands.dart';
import 'auth_state_viewmodel.dart';

class AuthCommandsViewModel {
  final AuthStateViewModel state;
  final EntrarComEmailCommand _entrarEmailCmd;
  final CadastrarUsuarioCommand _cadastrarCmd;
  final EntrarComGoogleCommand _entrarGoogleCmd;
  final SairCommand _sairCmd;

  AuthCommandsViewModel({
    required this.state,
    required EntrarComEmailCommand entrarEmailCmd,
    required CadastrarUsuarioCommand cadastrarCmd,
    required EntrarComGoogleCommand entrarGoogleCmd,
    required SairCommand sairCmd,
  })  : _entrarEmailCmd = entrarEmailCmd, _cadastrarCmd = cadastrarCmd,
        _entrarGoogleCmd = entrarGoogleCmd, _sairCmd = sairCmd;

  /// Retorna true em caso de sucesso; em falha, publica a mensagem no estado.
  Future<bool> entrarComEmail(String email, String senha) =>
      _executar(() => _entrarEmailCmd.executeWith((email: email, senha: senha)));

  Future<bool> cadastrar(String email, String senha) =>
      _executar(() => _cadastrarCmd.executeWith((email: email, senha: senha)));

  Future<bool> entrarComGoogle() => _executar(() => _entrarGoogleCmd.executeWith(()));

  Future<bool> sair() async {
    state.setLoading(true);
    final result = await _sairCmd.executeWith(());
    final ok = result.fold(
      onSuccess: (_) { state.setUsuario(null); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
    state.setLoading(false);
    return ok;
  }

  Future<bool> _executar(Future<UsuarioResult> Function() acao) async {
    state.limparMensagem();
    state.setLoading(true);
    final result = await acao();
    final ok = result.fold(
      onSuccess: (u) { state.setUsuario(u); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
    state.setLoading(false);
    return ok;
  }
}
