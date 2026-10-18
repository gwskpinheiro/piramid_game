import '../../core/typedefs/types_defs.dart';
import '../usecases/tema_usecases_interfaces.dart';
import 'tema_facade_usecases_interface.dart';

final class TemaFacadeUseCasesImpl implements ITemaFacadeUseCases {
  final IObterTemaUseCase _obter;
  final IAlterarTemaUseCase _alterar;

  TemaFacadeUseCasesImpl({
    required IObterTemaUseCase obter,
    required IAlterarTemaUseCase alterar,
  })  : _obter = obter, _alterar = alterar;

  @override Future<TemaResult> obterTema(NoParams params) => _obter(params);
  @override Future<VoidResult> alterarTema(TemaParams params) => _alterar(params);
}
