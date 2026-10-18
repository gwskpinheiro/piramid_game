import '../../domain/models/avaliacao_entity.dart';
import '../commands/avaliacao_commands.dart';
import 'avaliacao_state_viewmodel.dart';

class AvaliacaoCommandsViewModel {
  final AvaliacaoStateViewModel state;
  final VerificarAutoavaliacaoCommand _verificarCmd;
  final ConsultarAvaliacaoCommand _consultarCmd;
  final AvaliarPessoaCommand _avaliarCmd;
  final AlterarAvaliacaoCommand _alterarCmd;

  AvaliacaoCommandsViewModel({
    required this.state,
    required VerificarAutoavaliacaoCommand verificarCmd,
    required ConsultarAvaliacaoCommand consultarCmd,
    required AvaliarPessoaCommand avaliarCmd,
    required AlterarAvaliacaoCommand alterarCmd,
  })  : _verificarCmd = verificarCmd, _consultarCmd = consultarCmd,
        _avaliarCmd = avaliarCmd, _alterarCmd = alterarCmd;

  /// Muda a cada troca de usuário; respostas de uma sessão anterior são descartadas.
  int _sessao = 0;

  /// Remove permissão, avaliação e notas do usuário anterior (logout/troca de
  /// conta) e descarta requisições ainda em andamento.
  void limparDadosDoUsuario() {
    _sessao++;
    _verificarCmd.reset();
    _consultarCmd.reset();
    _avaliarCmd.reset();
    _alterarCmd.reset();
    state.limpar();
  }

  /// Carrega a permissão (vínculo/autoavaliação) e a avaliação já existente.
  ///
  /// Deve ser chamado fora da fase de build (ex.: addPostFrameCallback), pois
  /// altera signals observados por outras telas. Nunca deixa a tela presa em
  /// carregamento: qualquer falha vira uma mensagem em [erroCarregamento].
  Future<void> carregar(String pessoaId) async {
    // Se outro carregamento (ou outro usuário) começar no meio deste, o
    // resultado antigo é ignorado.
    final sessao = _sessao;
    bool atual() => sessao == _sessao && state.pessoaId.value == pessoaId;
    try {
      state.iniciar(pessoaId);
      state.isLoading.value = true;

      final permissao = await _verificarCmd.executeWith((id: pessoaId));
      if (!atual()) return;
      final verificou = permissao.fold(
        onSuccess: (p) { state.permissao.value = p; return true; },
        onFailure: (e) {
          state.erroCarregamento.value =
              'Não foi possível verificar se sua conta pode avaliar.\n${e.msg}';
          return false;
        },
      );

      if (verificou && state.permissao.value == PermissaoAvaliacao.permitida) {
        final existente = await _consultarCmd.executeWith((id: pessoaId));
        if (!atual()) return;
        existente.fold(
          onSuccess: state.setAvaliacao,
          // Sem saber se já existe avaliação, não exibimos o formulário: salvar
          // poderia tentar criar uma segunda avaliação (e seria recusado).
          onFailure: (e) => state.erroCarregamento.value =
              'Não foi possível carregar sua avaliação anterior.\n${e.msg}',
        );
      }
    } catch (e) {
      if (atual()) {
        state.erroCarregamento.value = 'Erro inesperado ao carregar a avaliação.\n$e';
      }
    } finally {
      if (atual()) state.isLoading.value = false;
    }
  }

  void alterarNota(CriteriosPopularidade criterios) => state.criterios.value = criterios;

  /// Registra (primeira vez) ou altera a avaliação existente.
  /// Retorna true em caso de sucesso; a mensagem de erro fica no estado.
  Future<bool> salvar() async {
    final pessoaId = state.pessoaId.value;
    if (pessoaId == null) return false;
    final sessao = _sessao;
    state.limparMensagem();
    state.isSaving.value = true;

    final params = (pessoaId: pessoaId, criterios: state.criterios.value);
    final result = state.jaAvaliou.value
        ? await _alterarCmd.executeWith(params)
        : await _avaliarCmd.executeWith(params);

    // Usuário trocou durante a gravação: não exibe o resultado ao novo usuário.
    if (sessao != _sessao) return false;

    final ok = result.fold(
      onSuccess: (a) {
        // Preserva a data de criação original ao alterar.
        state.setAvaliacao(state.avaliacaoAtual.value == null
            ? a
            : a.copyWith(createdAt: state.avaliacaoAtual.value!.createdAt));
        return true;
      },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
    state.isSaving.value = false;
    return ok;
  }
}
