import 'package:uuid/uuid.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/aluno_repository_interface.dart';
import '../../domain/models/aluno_entity.dart';
import 'aluno_usecases_interfaces.dart';

final class CadastrarAlunoUseCaseImpl implements ICadastrarAlunoUseCase {
  final IAlunoRepository _repository;
  final _uuid = const Uuid();

  CadastrarAlunoUseCaseImpl({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<AlunoResult> call(AlunoParams params) async {
    final aluno = params.aluno;
    if (aluno.nome.trim().isEmpty) {
      return r.Error(InputFailure('O nome do aluno é obrigatório.'));
    }
    final now = DateTime.now();
    final novoAluno = aluno.copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now);
    return _repository.salvarAluno(novoAluno);
  }
}

final class ObterTodosAlunosUseCaseImpl implements IObterTodosAlunosUseCase {
  final IAlunoRepository _repository;
  ObterTodosAlunosUseCaseImpl({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<ListAlunoResult> call(NoParams params) => _repository.obterTodosAlunos();
}

final class ObterAlunoPorIdUseCaseImpl implements IObterAlunoPorIdUseCase {
  final IAlunoRepository _repository;
  ObterAlunoPorIdUseCaseImpl({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<AlunoResult> call(AlunoIdParams params) =>
      _repository.obterAlunoPorId(params.id);
}

final class AtualizarAlunoUseCaseImpl implements IAtualizarAlunoUseCase {
  final IAlunoRepository _repository;
  AtualizarAlunoUseCaseImpl({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<AlunoResult> call(AlunoParams params) async {
    final aluno = params.aluno;
    if (aluno.nome.trim().isEmpty) {
      return r.Error(InputFailure('O nome do aluno é obrigatório.'));
    }
    return _repository.atualizarAluno(aluno.copyWith(updatedAt: DateTime.now()));
  }
}

final class DeletarAlunoUseCaseImpl implements IDeletarAlunoUseCase {
  final IAlunoRepository _repository;
  DeletarAlunoUseCaseImpl({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(AlunoIdParams params) =>
      _repository.deletarAluno(params.id);
}

final class CalcularRankingUseCaseImpl implements ICalcularRankingUseCase {
  final IAlunoRepository _repository;
  CalcularRankingUseCaseImpl({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<ListAlunoResult> call(NoParams params) async {
    final result = await _repository.obterTodosAlunos();
    return result.fold(
      onSuccess: (alunos) {
        final sorted = List<Aluno>.from(alunos)
          ..sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda));
        return Success(sorted);
      },
      onFailure: (f) => r.Error(f),
    );
  }
}
