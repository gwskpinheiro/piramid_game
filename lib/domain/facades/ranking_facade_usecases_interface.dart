import '../../core/typedefs/types_defs.dart';

abstract interface class IRankingFacadeUseCases {
  Future<RankingResult> gerarRankingPessoal(NoParams params);
  Future<RankingResult> gerarRankingGlobal(NoParams params);
}
