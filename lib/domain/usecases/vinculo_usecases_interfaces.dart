import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// pessoaId vinculado à conta autenticada (null se ainda não identificou o perfil).
abstract interface class IObterVinculoUseCase implements IUseCase<VinculoResult, NoParams> {}

/// Pessoas cadastradas que ainda não possuem conta vinculada.
abstract interface class IObterPessoasDisponiveisUseCase
    implements IUseCase<ListPessoaResult, NoParams> {}

/// Vincula a conta autenticada a uma pessoa já cadastrada.
abstract interface class IVincularPessoaExistenteUseCase
    implements IUseCase<VinculoResult, PessoaIdParams> {}

/// Cadastra o próprio perfil e o vincula à conta autenticada.
abstract interface class ICadastrarPerfilEVincularUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}
