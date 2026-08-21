import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/aluno_entity.dart';

class AlunoStateViewModel {
  final alunos = signal<List<Aluno>>([]);
  final mensagem = signal<String?>(null);
  final isLoading = signal<bool>(false);
  final alunoSelecionado = signal<Aluno?>(null);

  late final ranking = computed<List<Aluno>>(() {
    final lista = List<Aluno>.from(alunos.value);
    lista.sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda));
    return lista;
  });

  late final totalAlunos = computed<int>(() => alunos.value.length);

  void limparMensagem() => mensagem.value = null;
  void setMensagem(String msg) => mensagem.value = msg;
  void setLoading(bool value) => isLoading.value = value;
  void setAlunos(List<Aluno> lista) => alunos.value = lista;
  void adicionarAluno(Aluno aluno) => alunos.value = [...alunos.value, aluno];
  void atualizarAluno(Aluno aluno) =>
      alunos.value = alunos.value.map((a) => a.id == aluno.id ? aluno : a).toList();
  void removerAluno(String id) =>
      alunos.value = alunos.value.where((a) => a.id != id).toList();
  void selecionarAluno(Aluno? aluno) => alunoSelecionado.value = aluno;
}
