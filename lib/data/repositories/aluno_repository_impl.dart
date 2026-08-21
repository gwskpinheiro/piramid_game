import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno_entity.dart';
import '../services/aluno_local_storage_interface.dart';
import 'aluno_repository_interface.dart';

final class AlunoRepositoryImpl implements IAlunoRepository {
  final IAlunoLocalStorage _localStorage;

  AlunoRepositoryImpl({required IAlunoLocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<AlunoResult> salvarAluno(Aluno aluno) => _localStorage.salvarAluno(aluno);
  @override
  Future<ListAlunoResult> obterTodosAlunos() => _localStorage.obterTodosAlunos();
  @override
  Future<AlunoResult> obterAlunoPorId(String id) => _localStorage.obterAlunoPorId(id);
  @override
  Future<AlunoResult> atualizarAluno(Aluno aluno) => _localStorage.atualizarAluno(aluno);
  @override
  Future<VoidResult> deletarAluno(String id) => _localStorage.deletarAluno(id);
}
