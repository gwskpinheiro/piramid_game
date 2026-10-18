import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../commands/avaliacao_commands.dart';
import 'auth_viewmodel.dart';
import 'avaliacao_commands_viewmodel.dart';
import 'avaliacao_state_viewmodel.dart';
import 'sessao_usuario.dart';

class AvaliacaoViewModel {
  late final AvaliacaoStateViewModel avaliacaoState;
  late final AvaliacaoCommandsViewModel commands;

  AvaliacaoViewModel(IAvaliacaoFacadeUseCases facade, AuthViewModel auth) {
    avaliacaoState = AvaliacaoStateViewModel();
    commands = AvaliacaoCommandsViewModel(
      state: avaliacaoState,
      verificarCmd: VerificarAutoavaliacaoCommand(facade),
      consultarCmd: ConsultarAvaliacaoCommand(facade),
      avaliarCmd: AvaliarPessoaCommand(facade),
      alterarCmd: AlterarAvaliacaoCommand(facade),
    );
    aoTrocarUsuario(auth.authState.usuario, commands.limparDadosDoUsuario);
  }
}
