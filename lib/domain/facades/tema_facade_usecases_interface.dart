import '../../core/typedefs/types_defs.dart';

abstract interface class ITemaFacadeUseCases {
  Future<TemaResult> obterTema(NoParams params);
  Future<VoidResult> alterarTema(TemaParams params);
}
