import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno_entity.dart';

abstract interface class IAlunoLocalStorage {
  Future<AlunoResult> salvarAluno(Aluno aluno);
  Future<ListAlunoResult> obterTodosAlunos();
  Future<AlunoResult> obterAlunoPorId(String id);
  Future<AlunoResult> atualizarAluno(Aluno aluno);
  Future<VoidResult> deletarAluno(String id);
}
