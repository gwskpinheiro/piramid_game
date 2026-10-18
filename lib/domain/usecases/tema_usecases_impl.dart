import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/preference_repository_interface.dart';
import 'tema_usecases_interfaces.dart';

final class ObterTemaUseCaseImpl implements IObterTemaUseCase {
  final IPreferenceRepository _repository;
  ObterTemaUseCaseImpl({required IPreferenceRepository repository})
      : _repository = repository;

  @override
  Future<TemaResult> call(NoParams params) => _repository.obterTema();
}

final class AlterarTemaUseCaseImpl implements IAlterarTemaUseCase {
  final IPreferenceRepository _repository;
  AlterarTemaUseCaseImpl({required IPreferenceRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(TemaParams params) => _repository.salvarTema(params.tema);
}
