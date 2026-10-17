import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../../domain/models/ranking_entity.dart';

final class CarregarRankingPessoalCommand
    extends ParameterizedCommand<List<ItemRanking>, Failure, NoParams> {
  final IRankingFacadeUseCases _facade;
  CarregarRankingPessoalCommand(this._facade);
  @override
  Future<RankingResult> execute() => _facade.gerarRankingPessoal(());
}

final class CarregarRankingGlobalCommand
    extends ParameterizedCommand<List<ItemRanking>, Failure, NoParams> {
  final IRankingFacadeUseCases _facade;
  CarregarRankingGlobalCommand(this._facade);
  @override
  Future<RankingResult> execute() => _facade.gerarRankingGlobal(());
}
