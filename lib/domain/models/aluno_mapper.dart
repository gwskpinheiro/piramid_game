import 'aluno_entity.dart';

class AlunoMapper {
  static Map<String, dynamic> toMap(Aluno aluno) {
    return {
      'id': aluno.id,
      'nome': aluno.nome,
      'apelido': aluno.apelido,
      'curso': aluno.curso.name,
      'turmaAno': aluno.turmaAno,
      'dataNascimento': aluno.dataNascimento.toIso8601String(),
      'criterios': aluno.criterios.toMap(),
      'createdAt': aluno.createdAt.toIso8601String(),
      'updatedAt': aluno.updatedAt.toIso8601String(),
    };
  }

  static Aluno fromMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as String,
      nome: map['nome'] as String,
      apelido: map['apelido'] as String? ?? '',
      curso: Curso.values.byName(map['curso'] as String),
      turmaAno: map['turmaAno'] as int,
      dataNascimento: DateTime.parse(map['dataNascimento'] as String),
      criterios: CriteriosPopularidade.fromMap(
        Map<String, dynamic>.from(map['criterios'] as Map),
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
