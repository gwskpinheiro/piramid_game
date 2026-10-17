import '../commands/ranking_commands.dart';
import 'ranking_state_viewmodel.dart';

class RankingCommandsViewModel {
  final RankingStateViewModel state;
  final CarregarRankingPessoalCommand _pessoalCmd;
  final CarregarRankingGlobalCommand _globalCmd;

  RankingCommandsViewModel({
    required this.state,
    required CarregarRankingPessoalCommand pessoalCmd,
    required CarregarRankingGlobalCommand globalCmd,
  })  : _pessoalCmd = pessoalCmd, _globalCmd = globalCmd;

  Future<void> carregarRankingPessoal() async {
    state.erroPessoal.value = null;
    state.carregandoPessoal.value = true;
    try {
      final result = await _pessoalCmd.executeWith(());
      result.fold(
        onSuccess: (lista) => state.rankingPessoal.value = lista,
        onFailure: (e) => state.erroPessoal.value = e.msg,
      );
    } catch (e) {
      state.erroPessoal.value = 'Erro inesperado ao calcular o ranking pessoal.\n$e';
    } finally {
      state.carregandoPessoal.value = false;
    }
  }

  Future<void> carregarRankingGlobal() async {
    state.erroGlobal.value = null;
    state.carregandoGlobal.value = true;
    try {
      final result = await _globalCmd.executeWith(());
      result.fold(
        onSuccess: (lista) => state.rankingGlobal.value = lista,
        onFailure: (e) => state.erroGlobal.value = e.msg,
      );
    } catch (e) {
      state.erroGlobal.value = 'Erro inesperado ao calcular o ranking global.\n$e';
    } finally {
      state.carregandoGlobal.value = false;
    }
  }
}
