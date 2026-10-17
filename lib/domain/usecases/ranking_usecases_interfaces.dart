import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Ranking pessoal: apenas avaliações feitas pelo usuário autenticado.
abstract interface class ICalcularRankingPessoalUseCase
    implements IUseCase<RankingResult, NoParams> {}

/// Ranking global: média das avaliações recebidas de todos os usuários.
abstract interface class ICalcularRankingGlobalUseCase
    implements IUseCase<RankingResult, NoParams> {}
