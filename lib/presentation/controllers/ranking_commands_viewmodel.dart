import '../commands/ranking_commands.dart';
import 'ranking_state_viewmodel.dart';

class RankingCommandsViewModel {
  final RankingStateViewModel state;
  final CarregarRankingPessoalCommand _pessoalCmd;
  final CarregarRankingGlobalCommand _globalCmd;

  /// Muda a cada troca de usuário; respostas de uma sessão anterior são descartadas.
  int _sessao = 0;

  RankingCommandsViewModel({
    required this.state,
    required CarregarRankingPessoalCommand pessoalCmd,
    required CarregarRankingGlobalCommand globalCmd,
  })  : _pessoalCmd = pessoalCmd, _globalCmd = globalCmd;

  Future<void> carregarRankingPessoal() async {
    final sessao = _sessao;
    bool atual() => sessao == _sessao;
    state.erroPessoal.value = null;
    state.carregandoPessoal.value = true;
    try {
      final result = await _pessoalCmd.executeWith(());
      if (!atual()) return;
      result.fold(
        onSuccess: (lista) => state.rankingPessoal.value = lista,
        onFailure: (e) => state.erroPessoal.value = e.msg,
      );
    } catch (e) {
      if (atual()) {
        state.erroPessoal.value = 'Erro inesperado ao calcular o ranking pessoal.\n$e';
      }
    } finally {
      if (atual()) state.carregandoPessoal.value = false;
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

  /// Remove o ranking pessoal do usuário anterior (logout/troca de conta).
  /// O ranking global é o mesmo para todos e é preservado.
  void limparDadosDoUsuario() {
    _sessao++;
    _pessoalCmd.reset();
    state.limparPessoal();
  }
}
