import 'aluno_entity.dart';

class AlunoMapper {
  static Map<String, dynamic> toMap(Aluno aluno) => {
    'id': aluno.id,
    'nome': aluno.nome,
    'apelido': aluno.apelido,
    'curso': aluno.curso.name,
    'turmaAno': aluno.turmaAno,
    'dataNascimento': aluno.dataNascimento.toIso8601String(),
    'createdAt': aluno.createdAt.toIso8601String(),
    'updatedAt': aluno.updatedAt.toIso8601String(),
    ...aluno.criterios.toMap(),
  };

  static Aluno fromMap(Map<String, dynamic> map) => Aluno(
    id: map['id'] as String,
    nome: map['nome'] as String,
    apelido: map['apelido'] as String? ?? '',
    curso: Curso.values.byName(map['curso'] as String),
    turmaAno: map['turmaAno'] as int,
    dataNascimento: DateTime.parse(map['dataNascimento'] as String),
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
    criterios: CriteriosPopularidade.fromMap(map),
  );
}
