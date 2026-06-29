import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/aluno_entity.dart';

class AlunoStateViewModel {
  /// Lista reativa de alunos
  final alunos = signal<List<Aluno>>([]);

  /// Mensagem de feedback (erro ou sucesso)
  final mensagem = signal<String?>(null);

  /// Indica se está carregando dados
  final isLoading = signal<bool>(false);

  /// Aluno selecionado para edição/detalhe
  final alunoSelecionado = signal<Aluno?>(null);

  /// Ranking: alunos ordenados por nivelLenda
  late final ranking = computed<List<Aluno>>(() {
    final lista = List<Aluno>.from(alunos.value);
    lista.sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda));
    return lista;
  });

  /// Total de alunos cadastrados
  late final totalAlunos = computed<int>(() => alunos.value.length);

  void limparMensagem() => mensagem.value = null;
  void setMensagem(String msg) => mensagem.value = msg;

  void setLoading(bool value) => isLoading.value = value;

  void setAlunos(List<Aluno> lista) => alunos.value = lista;

  void adicionarAluno(Aluno aluno) {
    alunos.value = [...alunos.value, aluno];
  }

  void atualizarAluno(Aluno aluno) {
    alunos.value = alunos.value
        .map((a) => a.id == aluno.id ? aluno : a)
        .toList();
  }

  void removerAluno(String id) {
    alunos.value = alunos.value.where((a) => a.id != id).toList();
  }

  void selecionarAluno(Aluno? aluno) => alunoSelecionado.value = aluno;
}
