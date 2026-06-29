import '../../core/typedefs/types_defs.dart';

abstract interface class IAlunoFacadeUseCases {
  Future<AlunoResult> cadastrarAluno(AlunoParams params);
  Future<ListAlunoResult> obterTodosAlunos(NoParams params);
  Future<AlunoResult> obterAlunoPorId(AlunoIdParams params);
  Future<AlunoResult> atualizarAluno(AlunoParams params);
  Future<VoidResult> deletarAluno(AlunoIdParams params);
  Future<ListAlunoResult> calcularRanking(NoParams params);
}
