import '../../core/typedefs/types_defs.dart';
import '../usecases/aluno_usecases_interfaces.dart';
import 'aluno_facade_usecases_interface.dart';

final class AlunoFacadeUseCasesImpl implements IAlunoFacadeUseCases {
  final ICadastrarAlunoUseCase _cadastrar;
  final IObterTodosAlunosUseCase _obterTodos;
  final IObterAlunoPorIdUseCase _obterPorId;
  final IAtualizarAlunoUseCase _atualizar;
  final IDeletarAlunoUseCase _deletar;
  final ICalcularRankingUseCase _ranking;

  AlunoFacadeUseCasesImpl({
    required ICadastrarAlunoUseCase cadastrar,
    required IObterTodosAlunosUseCase obterTodos,
    required IObterAlunoPorIdUseCase obterPorId,
    required IAtualizarAlunoUseCase atualizar,
    required IDeletarAlunoUseCase deletar,
    required ICalcularRankingUseCase ranking,
  })  : _cadastrar = cadastrar, _obterTodos = obterTodos, _obterPorId = obterPorId,
        _atualizar = atualizar, _deletar = deletar, _ranking = ranking;

  @override Future<AlunoResult> cadastrarAluno(AlunoParams params) => _cadastrar(params);
  @override Future<ListAlunoResult> obterTodosAlunos(NoParams params) => _obterTodos(params);
  @override Future<AlunoResult> obterAlunoPorId(AlunoIdParams params) => _obterPorId(params);
  @override Future<AlunoResult> atualizarAluno(AlunoParams params) => _atualizar(params);
  @override Future<VoidResult> deletarAluno(AlunoIdParams params) => _deletar(params);
  @override Future<ListAlunoResult> calcularRanking(NoParams params) => _ranking(params);
}
