import '../../domain/models/aluno_entity.dart';
import '../commands/aluno_commands.dart';
import 'aluno_state_viewmodel.dart';

class AlunoCommandsViewModel {
  final AlunoStateViewModel state;
  final ObterTodosAlunosCommand _obterTodosCmd;
  final CadastrarAlunoCommand _cadastrarCmd;
  final AtualizarAlunoCommand _atualizarCmd;
  final DeletarAlunoCommand _deletarCmd;
  final CalcularRankingCommand _rankingCmd;
  final BuscarAlunoPorIdCommand _buscarPorIdCmd;

  AlunoCommandsViewModel({
    required this.state,
    required ObterTodosAlunosCommand obterTodosCmd,
    required CadastrarAlunoCommand cadastrarCmd,
    required AtualizarAlunoCommand atualizarCmd,
    required DeletarAlunoCommand deletarCmd,
    required CalcularRankingCommand rankingCmd,
    required BuscarAlunoPorIdCommand buscarPorIdCmd,
  })  : _obterTodosCmd = obterTodosCmd, _cadastrarCmd = cadastrarCmd,
        _atualizarCmd = atualizarCmd, _deletarCmd = deletarCmd,
        _rankingCmd = rankingCmd, _buscarPorIdCmd = buscarPorIdCmd;

  Future<void> carregarAlunos() async {
    state.setLoading(true);
    final result = await _obterTodosCmd.executeWith(());
    result.fold(onSuccess: state.setAlunos, onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<void> cadastrarAluno(Aluno aluno) async {
    state.setLoading(true);
    final result = await _cadastrarCmd.executeWith((aluno: aluno));
    result.fold(onSuccess: state.adicionarAluno, onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<void> atualizarAluno(Aluno aluno) async {
    state.setLoading(true);
    final result = await _atualizarCmd.executeWith((aluno: aluno));
    result.fold(onSuccess: state.atualizarAluno, onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<void> deletarAluno(String id) async {
    state.setLoading(true);
    final result = await _deletarCmd.executeWith((id: id));
    result.fold(onSuccess: (_) => state.removerAluno(id), onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<void> carregarRanking() async {
    state.setLoading(true);
    final result = await _rankingCmd.executeWith(());
    result.fold(onSuccess: state.setAlunos, onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<Aluno?> buscarAlunoPorId(String id) async {
    final result = await _buscarPorIdCmd.executeWith((id: id));
    return result.fold(
      onSuccess: (aluno) { state.selecionarAluno(aluno); return aluno; },
      onFailure: (e) { state.setMensagem(e.msg); return null; },
    );
  }
}
