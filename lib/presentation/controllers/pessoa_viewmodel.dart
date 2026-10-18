import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../commands/pessoa_commands.dart';
import 'auth_viewmodel.dart';
import 'pessoa_commands_viewmodel.dart';
import 'pessoa_state_viewmodel.dart';
import 'sessao_usuario.dart';

class PessoaViewModel {
  late final PessoaStateViewModel pessoaState;
  late final PessoaCommandsViewModel commands;

  PessoaViewModel(IPessoaFacadeUseCases facade, AuthViewModel auth) {
    pessoaState = PessoaStateViewModel();
    commands = PessoaCommandsViewModel(
      state: pessoaState,
      obterTodasCmd: ObterTodasPessoasCommand(facade),
      cadastrarCmd: CadastrarPessoaCommand(facade),
      atualizarCmd: AtualizarPessoaCommand(facade),
      deletarCmd: DeletarPessoaCommand(facade),
      buscarPorIdCmd: BuscarPessoaPorIdCommand(facade),
    );
    aoTrocarUsuario(auth.authState.usuario, commands.limparDadosDoUsuario);
  }
}
