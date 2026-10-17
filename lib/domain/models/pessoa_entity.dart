import 'package:equatable/equatable.dart';

import 'curso.dart';

export 'curso.dart';

/// Pessoa cadastrada para ser avaliada. Contém apenas dados cadastrais;
/// as notas ficam em Avaliacao.
class Pessoa extends Equatable {
  final String id;
  final String nome;
  final String apelido;
  final Curso curso;
  final int turmaAno;
  final DateTime dataNascimento;
  /// uid do usuário que fez o cadastro (único que pode editar/excluir).
  final String criadoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pessoa({
    required this.id, required this.nome, required this.apelido,
    required this.curso, required this.turmaAno, required this.dataNascimento,
    required this.criadoPor, required this.createdAt, required this.updatedAt,
  });

  Pessoa copyWith({
    String? id, String? nome, String? apelido, Curso? curso, int? turmaAno,
    DateTime? dataNascimento, String? criadoPor,
    DateTime? createdAt, DateTime? updatedAt,
  }) {
    return Pessoa(
      id: id ?? this.id, nome: nome ?? this.nome, apelido: apelido ?? this.apelido,
      curso: curso ?? this.curso, turmaAno: turmaAno ?? this.turmaAno,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      criadoPor: criadoPor ?? this.criadoPor,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, nome, apelido, curso, turmaAno, dataNascimento, criadoPor, createdAt, updatedAt,
  ];

  @override
  String toString() =>
      'Pessoa(id: $id, nome: $nome, curso: ${curso.displayName}, turma: $turmaAno)';
}
