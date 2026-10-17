import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class ICadastrarPessoaUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}

abstract interface class IObterTodasPessoasUseCase
    implements IUseCase<ListPessoaResult, NoParams> {}

abstract interface class IObterPessoaPorIdUseCase
    implements IUseCase<PessoaResult, PessoaIdParams> {}

abstract interface class IAtualizarPessoaUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}

abstract interface class IDeletarPessoaUseCase
    implements IUseCase<VoidResult, PessoaIdParams> {}
