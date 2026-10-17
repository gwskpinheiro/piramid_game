import 'package:equatable/equatable.dart';

import 'avaliacao_entity.dart';
import 'curso.dart';

export 'avaliacao_entity.dart' show CriteriosPopularidade, listaCriterios;
export 'curso.dart';

/// Modelo legado (SQLite): pessoa + notas no mesmo registro.
/// Mantido até a migração das avaliações/rankings para o Firestore.
class Aluno extends Equatable {
  final String id;
  final String nome;
  final String apelido;
  final Curso curso;
  final int turmaAno;
  final DateTime dataNascimento;
  final CriteriosPopularidade criterios;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Aluno({
    required this.id, required this.nome, required this.apelido,
    required this.curso, required this.turmaAno, required this.dataNascimento,
    required this.criterios, required this.createdAt, required this.updatedAt,
  });

  int get nivelLenda => criterios.nivelLenda;

  Aluno copyWith({
    String? id, String? nome, String? apelido, Curso? curso,
    int? turmaAno, DateTime? dataNascimento, CriteriosPopularidade? criterios,
    DateTime? createdAt, DateTime? updatedAt,
  }) {
    return Aluno(
      id: id ?? this.id, nome: nome ?? this.nome, apelido: apelido ?? this.apelido,
      curso: curso ?? this.curso, turmaAno: turmaAno ?? this.turmaAno,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      criterios: criterios ?? this.criterios,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, nome, apelido, curso, turmaAno, dataNascimento, criterios, createdAt, updatedAt,
  ];

  @override
  String toString() =>
      'Aluno(id: $id, nome: $nome, curso: ${curso.displayName}, nivelLenda: $nivelLenda)';
}
