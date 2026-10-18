import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../commands/ranking_commands.dart';
import 'auth_viewmodel.dart';
import 'ranking_commands_viewmodel.dart';
import 'ranking_state_viewmodel.dart';
import 'sessao_usuario.dart';

class RankingViewModel {
  late final RankingStateViewModel rankingState;
  late final RankingCommandsViewModel commands;

  RankingViewModel(IRankingFacadeUseCases facade, AuthViewModel auth) {
    rankingState = RankingStateViewModel();
    commands = RankingCommandsViewModel(
      state: rankingState,
      pessoalCmd: CarregarRankingPessoalCommand(facade),
      globalCmd: CarregarRankingGlobalCommand(facade),
    );
    aoTrocarUsuario(auth.authState.usuario, commands.limparDadosDoUsuario);
  }
}
