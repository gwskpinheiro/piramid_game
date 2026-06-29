import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../commands/aluno_commands.dart';
import 'aluno_commands_viewmodel.dart';
import 'aluno_state_viewmodel.dart';

class AlunoViewModel {
  late final AlunoStateViewModel alunoState;
  late final AlunoCommandsViewModel commands;

  AlunoViewModel(IAlunoFacadeUseCases facade) {
    alunoState = AlunoStateViewModel();
    commands = AlunoCommandsViewModel(
      state: alunoState,
      obterTodosCmd: ObterTodosAlunosCommand(facade),
      cadastrarCmd: CadastrarAlunoCommand(facade),
      atualizarCmd: AtualizarAlunoCommand(facade),
      deletarCmd: DeletarAlunoCommand(facade),
      rankingCmd: CalcularRankingCommand(facade),
      buscarPorIdCmd: BuscarAlunoPorIdCommand(facade),
    );
  }
}
