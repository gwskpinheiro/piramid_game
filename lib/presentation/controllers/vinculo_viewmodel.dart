import 'package:signals_flutter/signals_flutter.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../domain/facades/vinculo_facade_usecases_interface.dart';
import '../../domain/models/pessoa_entity.dart';
import '../commands/vinculo_commands.dart';
import 'auth_viewmodel.dart';

/// Identificação do próprio perfil: verifica se a conta já está vinculada a
/// uma pessoa e permite vincular (perfil existente ou cadastro do próprio).
class VinculoViewModel {
  final VerificarVinculoCommand _verificarCmd;
  final CarregarPessoasDisponiveisCommand _disponiveisCmd;
  final VincularPessoaCommand _vincularCmd;
  final CadastrarPerfilEVincularCommand _cadastrarCmd;

  /// null = ainda não verificado; o roteador só libera a Home quando true.
  final possuiVinculo = signal<bool?>(null);
  final verificando = signal<bool>(false);
  final erroVerificacao = signal<String?>(null);

  final pessoasDisponiveis = signal<List<Pessoa>>([]);
  final carregandoPessoas = signal<bool>(false);
  final erroPessoas = signal<String?>(null);

  final salvando = signal<bool>(false);
  final mensagem = signal<String?>(null);

  /// Muda a cada troca de usuário; respostas de uma sessão anterior são descartadas.
  int _sessao = 0;

  VinculoViewModel(IVinculoFacadeUseCases facade, AuthViewModel auth)
      : _verificarCmd = VerificarVinculoCommand(facade),
        _disponiveisCmd = CarregarPessoasDisponiveisCommand(facade),
        _vincularCmd = VincularPessoaCommand(facade),
        _cadastrarCmd = CadastrarPerfilEVincularCommand(facade) {
    // Logout ou outra conta: limpa o estado e, se houver usuário, verifica de novo.
    final usuario = auth.authState.usuario;
    var uidAnterior = usuario.peek()?.uid;
    effect(() {
      final uid = usuario.value?.uid;
      if (uid == uidAnterior) return;
      uidAnterior = uid;
      untracked(() {
        _limpar();
        if (uid != null) verificarVinculo();
      });
    });
  }

  void _limpar() {
    _sessao++;
    _verificarCmd.reset();
    _disponiveisCmd.reset();
    _vincularCmd.reset();
    _cadastrarCmd.reset();
    possuiVinculo.value = null;
    verificando.value = false;
    erroVerificacao.value = null;
    pessoasDisponiveis.value = [];
    carregandoPessoas.value = false;
    erroPessoas.value = null;
    salvando.value = false;
    mensagem.value = null;
  }

  Future<void> verificarVinculo() async {
    final sessao = _sessao;
    erroVerificacao.value = null;
    verificando.value = true;
    final result = await _verificarCmd.executeWith(());
    if (sessao != _sessao) return;
    result.fold(
      onSuccess: (pessoaId) => possuiVinculo.value = pessoaId != null,
      onFailure: (e) => erroVerificacao.value = e.msg,
    );
    verificando.value = false;
  }

  Future<void> carregarPessoasDisponiveis() async {
    final sessao = _sessao;
    erroPessoas.value = null;
    carregandoPessoas.value = true;
    final result = await _disponiveisCmd.executeWith(());
    if (sessao != _sessao) return;
    result.fold(
      onSuccess: (lista) => pessoasDisponiveis.value = lista,
      onFailure: (e) => erroPessoas.value = e.msg,
    );
    carregandoPessoas.value = false;
  }

  /// Vincula a conta a uma pessoa existente. Em caso de recusa (ex.: outra
  /// conta vinculou o mesmo perfil antes), recarrega a lista e o vínculo.
  Future<bool> vincularPessoa(String pessoaId) =>
      _salvar(() => _vincularCmd.executeWith((id: pessoaId)));

  /// Cadastra o próprio perfil e o vincula à conta.
  Future<bool> cadastrarPerfil(Pessoa pessoa) =>
      _salvar(() => _cadastrarCmd.executeWith((pessoa: pessoa)));

  Future<bool> _salvar(Future<Result<Object?, Failure>> Function() acao) async {
    final sessao = _sessao;
    mensagem.value = null;
    salvando.value = true;
    final result = await acao();
    if (sessao != _sessao) return false;
    salvando.value = false;
    final ok = result.isSuccess;
    if (ok) {
      possuiVinculo.value = true; // o roteador leva à Home
    } else {
      mensagem.value = result.failureValueOrNull?.msg;
      carregarPessoasDisponiveis();
      verificarVinculo();
    }
    return ok;
  }
}
