import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class ICadastrarAlunoUseCase
    implements IUseCase<AlunoResult, AlunoParams> {}

abstract interface class IObterTodosAlunosUseCase
    implements IUseCase<ListAlunoResult, NoParams> {}

abstract interface class IObterAlunoPorIdUseCase
    implements IUseCase<AlunoResult, AlunoIdParams> {}

abstract interface class IAtualizarAlunoUseCase
    implements IUseCase<AlunoResult, AlunoParams> {}

abstract interface class IDeletarAlunoUseCase
    implements IUseCase<VoidResult, AlunoIdParams> {}

abstract interface class ICalcularRankingUseCase
    implements IUseCase<ListAlunoResult, NoParams> {}
