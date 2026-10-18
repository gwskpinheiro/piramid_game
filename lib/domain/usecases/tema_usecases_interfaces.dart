import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Recupera a preferência de tema salva no aparelho.
abstract interface class IObterTemaUseCase implements IUseCase<TemaResult, NoParams> {}

/// Altera (e salva) o tema do aplicativo.
abstract interface class IAlterarTemaUseCase implements IUseCase<VoidResult, TemaParams> {}
