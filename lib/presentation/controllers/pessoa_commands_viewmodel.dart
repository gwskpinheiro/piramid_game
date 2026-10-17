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

  Future<void> carregarPessoas() async {
    state.limparMensagem();
    state.setLoading(true);
    final result = await _obterTodasCmd.executeWith(());
    result.fold(onSuccess: state.setPessoas, onFailure: (e) => state.setMensagem(e.msg));
    state.setLoading(false);
  }

  Future<bool> cadastrarPessoa(Pessoa pessoa) async {
    state.limparMensagem();
    final result = await _cadastrarCmd.executeWith((pessoa: pessoa));
    return result.fold(
      onSuccess: (p) { state.adicionarPessoa(p); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
  }

  Future<bool> atualizarPessoa(Pessoa pessoa) async {
    state.limparMensagem();
    final result = await _atualizarCmd.executeWith((pessoa: pessoa));
    return result.fold(
      onSuccess: (p) { state.atualizarPessoa(p); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
  }

  Future<bool> deletarPessoa(String id) async {
    state.limparMensagem();
    final result = await _deletarCmd.executeWith((id: id));
    return result.fold(
      onSuccess: (_) { state.removerPessoa(id); return true; },
      onFailure: (e) { state.setMensagem(e.msg); return false; },
    );
  }

  Future<Pessoa?> buscarPessoaPorId(String id) async {
    final result = await _buscarPorIdCmd.executeWith((id: id));
    return result.fold(
      onSuccess: (p) { state.selecionarPessoa(p); return p; },
      onFailure: (e) { state.setMensagem(e.msg); return null; },
    );
  }
}
