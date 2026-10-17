import '../../core/typedefs/types_defs.dart';
import '../usecases/ranking_usecases_interfaces.dart';
import 'ranking_facade_usecases_interface.dart';

final class RankingFacadeUseCasesImpl implements IRankingFacadeUseCases {
  final ICalcularRankingPessoalUseCase _pessoal;
  final ICalcularRankingGlobalUseCase _global;

  RankingFacadeUseCasesImpl({
    required ICalcularRankingPessoalUseCase pessoal,
    required ICalcularRankingGlobalUseCase global,
  })  : _pessoal = pessoal, _global = global;

  @override Future<RankingResult> gerarRankingPessoal(NoParams params) => _pessoal(params);
  @override Future<RankingResult> gerarRankingGlobal(NoParams params) => _global(params);
}
