import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/pessoa_entity.dart';

class PessoaStateViewModel {
  final pessoas = signal<List<Pessoa>>([]);
  final mensagem = signal<String?>(null);
  final isLoading = signal<bool>(false);
  final pessoaSelecionada = signal<Pessoa?>(null);

  late final totalPessoas = computed<int>(() => pessoas.value.length);

  void limparMensagem() => mensagem.value = null;
  void setMensagem(String msg) => mensagem.value = msg;
  void setLoading(bool value) => isLoading.value = value;
  void setPessoas(List<Pessoa> lista) => pessoas.value = lista;
  void adicionarPessoa(Pessoa p) => pessoas.value = [...pessoas.value, p]
    ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  void atualizarPessoa(Pessoa p) =>
      pessoas.value = pessoas.value.map((x) => x.id == p.id ? p : x).toList();
  void removerPessoa(String id) =>
      pessoas.value = pessoas.value.where((x) => x.id != id).toList();
  void selecionarPessoa(Pessoa? p) => pessoaSelecionada.value = p;

  /// Remove os dados da sessão anterior (logout/troca de conta).
  void limpar() {
    pessoas.value = [];
    mensagem.value = null;
    isLoading.value = false;
    pessoaSelecionada.value = null;
  }
}
