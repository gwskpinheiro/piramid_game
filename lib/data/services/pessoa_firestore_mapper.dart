import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/pessoa_entity.dart';

/// Conversão entre [Pessoa] e documentos da coleção `pessoas` no Firestore.
class PessoaFirestoreMapper {
  /// Campos editáveis pelo usuário (não inclui criadoPor nem datas de controle).
  static Map<String, dynamic> camposEditaveis(Pessoa p) => {
    'nome': p.nome,
    'apelido': p.apelido,
    'curso': p.curso.name,
    'turmaAno': p.turmaAno,
    'dataNascimento': Timestamp.fromDate(p.dataNascimento),
  };

  static Pessoa fromFirestore(String id, Map<String, dynamic> map) => Pessoa(
    id: id,
    nome: map['nome'] as String? ?? '',
    apelido: map['apelido'] as String? ?? '',
    curso: Curso.values.asNameMap()[map['curso']] ?? Curso.tads,
    turmaAno: (map['turmaAno'] as num?)?.toInt() ?? DateTime.now().year,
    dataNascimento: _toDate(map['dataNascimento']),
    criadoPor: map['criadoPor'] as String? ?? '',
    createdAt: _toDate(map['createdAt']),
    updatedAt: _toDate(map['updatedAt']),
  );

  // serverTimestamp() pode chegar nulo em escritas locais ainda não confirmadas.
  static DateTime _toDate(Object? v) =>
      v is Timestamp ? v.toDate() : DateTime.now();
}
