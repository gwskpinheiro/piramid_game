import '../../domain/models/pessoa_entity.dart';
import '../commands/pessoa_commands.dart';
import 'pessoa_state_viewmodel.dart';

/// Os métodos de escrita retornam true em caso de sucesso; em falha,
/// a mensagem amigável fica em [PessoaStateViewModel.mensagem].
class PessoaCommandsViewModel {
  final PessoaStateViewModel state;
  final ObterTodasPessoasCommand _obterTodasCmd;
  final CadastrarPessoaCommand _cadastrarCmd;
  final AtualizarPessoaCommand _atualizarCmd;
  final DeletarPessoaCommand _deletarCmd;
  final BuscarPessoaPorIdCommand _buscarPorIdCmd;

  PessoaCommandsViewModel({
    required this.state,
    required ObterTodasPessoasCommand obterTodasCmd,
    required CadastrarPessoaCommand cadastrarCmd,
    required AtualizarPessoaCommand atualizarCmd,
    required DeletarPessoaCommand deletarCmd,
    required BuscarPessoaPorIdCommand buscarPorIdCmd,
  })  : _obterTodasCmd = obterTodasCmd, _cadastrarCmd = cadastrarCmd,
        _atualizarCmd = atualizarCmd, _deletarCmd = deletarCmd,
        _buscarPorIdCmd = buscarPorIdCmd;

  /// Muda a cada troca de usuário; respostas de uma sessão anterior são descartadas.
  int _sessao = 0;

  /// Remove os dados da sessão anterior (logout/troca de conta) e descarta
  /// requisições ainda em andamento.
  void limparDadosDoUsuario() {
    _sessao++;
    _obterTodasCmd.reset();
    _cadastrarCmd.reset();
    _atualizarCmd.reset();
    _deletarCmd.reset();
    _buscarPorIdCmd.reset();
    state.limpar();
  }

  Future<void> carregarPessoas() async {
    final sessao = _sessao;
    state.limparMensagem();
    state.setLoading(true);
    final result = await _obterTodasCmd.executeWith(());
    if (sessao != _sessao) return;
    result.fold(onSuccess: state.setPessoas, onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<bool> cadastrarPessoa(Pessoa pessoa) async {
    final sessao = _sessao;
    state.limparMensagem();
    final result = await _cadastrarCmd.executeWith((pessoa: pessoa));
    if (sessao != _sessao) return false;
    return result.fold(
      onSuccess: (p) { state.adicionarPessoa(p); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
  }

  Future<bool> atualizarPessoa(Pessoa pessoa) async {
    final sessao = _sessao;
    state.limparMensagem();
    final result = await _atualizarCmd.executeWith((pessoa: pessoa));
    if (sessao != _sessao) return false;
    return result.fold(
      onSuccess: (p) { state.atualizarPessoa(p); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
  }

  Future<bool> deletarPessoa(String id) async {
    final sessao = _sessao;
    state.limparMensagem();
    final result = await _deletarCmd.executeWith((id: id));
    if (sessao != _sessao) return false;
    return result.fold(
      onSuccess: (_) { state.removerPessoa(id); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
  }

  Future<Pessoa?> buscarPessoaPorId(String id) async {
    final sessao = _sessao;
    final result = await _buscarPorIdCmd.executeWith((id: id));
    if (sessao != _sessao) return null;
    return result.fold(
      onSuccess: (p) { state.selecionarPessoa(p); return p; },
      onFailure: (e) { state.setMensagem(e.msg); return null; },
    );
  }
}
