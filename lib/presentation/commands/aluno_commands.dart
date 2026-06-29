import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../../domain/models/aluno_entity.dart';

/// Busca todos os alunos
final class ObterTodosAlunosCommand
    extends ParameterizedCommand<List<Aluno>, Failure, NoParams> {
  final IAlunoFacadeUseCases _facade;
  ObterTodosAlunosCommand(this._facade);

  @override
  Future<ListAlunoResult> execute() => _facade.obterTodosAlunos(());
}

/// Cadastra um novo aluno
final class CadastrarAlunoCommand
    extends ParameterizedCommand<Aluno, Failure, AlunoParams> {
  final IAlunoFacadeUseCases _facade;
  CadastrarAlunoCommand(this._facade);

  @override
  Future<AlunoResult> execute() async {
    if (parameter == null) {
      return r.Error(InputFailure('Parâmetro nulo para cadastrar aluno.'));
    }
    return _facade.cadastrarAluno(parameter!);
  }
}

/// Atualiza um aluno existente
final class AtualizarAlunoCommand
    extends ParameterizedCommand<Aluno, Failure, AlunoParams> {
  final IAlunoFacadeUseCases _facade;
  AtualizarAlunoCommand(this._facade);

  @override
  Future<AlunoResult> execute() async {
    if (parameter == null) {
      return r.Error(InputFailure('Parâmetro nulo para atualizar aluno.'));
    }
    return _facade.atualizarAluno(parameter!);
  }
}

/// Deleta um aluno
final class DeletarAlunoCommand
    extends ParameterizedCommand<void, Failure, AlunoIdParams> {
  final IAlunoFacadeUseCases _facade;
  DeletarAlunoCommand(this._facade);

  @override
  Future<VoidResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) {
      return r.Error(InputFailure('ID inválido para deletar aluno.'));
    }
    return _facade.deletarAluno(parameter!);
  }
}

/// Calcula e retorna o ranking
final class CalcularRankingCommand
    extends ParameterizedCommand<List<Aluno>, Failure, NoParams> {
  final IAlunoFacadeUseCases _facade;
  CalcularRankingCommand(this._facade);

  @override
  Future<ListAlunoResult> execute() => _facade.calcularRanking(());
}

/// Busca aluno por ID
final class BuscarAlunoPorIdCommand
    extends ParameterizedCommand<Aluno, Failure, AlunoIdParams> {
  final IAlunoFacadeUseCases _facade;
  BuscarAlunoPorIdCommand(this._facade);

  @override
  Future<AlunoResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) {
      return r.Error(InputFailure('ID inválido para busca.'));
    }
    return _facade.obterAlunoPorId(parameter!);
  }
}
