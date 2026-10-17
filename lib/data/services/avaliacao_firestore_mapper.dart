import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/avaliacao_entity.dart';

/// Conversão entre [Avaliacao] e documentos da coleção `avaliacoes`.
/// Os nomes dos campos seguem a estrutura de referência da especificação.
class AvaliacaoFirestoreMapper {
  static Map<String, dynamic> notas(CriteriosPopularidade c) => {
    'resenha': c.resenha,
    'presencaVip': c.presencaVip,
    'aura': c.aura,
    'modoParceiro': c.modoParceiro,
    'carismaNatural': c.carisma,
    'humorDeMilhoes': c.humorMilhoes,
    'energiaDeGrupo': c.energiaGrupo,
    'criatividadeCaotica': c.criatividadeCaotica,
    'modoAtleta': c.modoAtleta,
    'talentoDePalco': c.talentopalco,
    'dripEscolar': c.dripEscolar,
    'coracaoDeDorama': c.coracaoDorama,
    'queridinhoProfessores': c.queridinhoProf,
    'cerebroTurbo': c.cerebroTurbo,
    'caosControlado': c.caosControlado,
    'pontuacaoTotal': c.nivelLenda,
  };

  static Avaliacao fromFirestore(String id, Map<String, dynamic> m) => Avaliacao(
    id: id,
    pessoaId: m['pessoaId'] as String? ?? '',
    avaliadorUid: m['avaliadorUid'] as String? ?? '',
    criterios: CriteriosPopularidade(
      resenha: _nota(m['resenha']),
      presencaVip: _nota(m['presencaVip']),
      aura: _nota(m['aura']),
      modoParceiro: _nota(m['modoParceiro']),
      carisma: _nota(m['carismaNatural']),
      humorMilhoes: _nota(m['humorDeMilhoes']),
      energiaGrupo: _nota(m['energiaDeGrupo']),
      criatividadeCaotica: _nota(m['criatividadeCaotica']),
      modoAtleta: _nota(m['modoAtleta']),
      talentopalco: _nota(m['talentoDePalco']),
      dripEscolar: _nota(m['dripEscolar']),
      coracaoDorama: _nota(m['coracaoDeDorama']),
      queridinhoProf: _nota(m['queridinhoProfessores']),
      cerebroTurbo: _nota(m['cerebroTurbo']),
      caosControlado: _nota(m['caosControlado']),
    ),
    createdAt: _toDate(m['createdAt']),
    dataAvaliacao: _toDate(m['dataAvaliacao']),
  );

  static int _nota(Object? v) => ((v as num?)?.toInt() ?? 1).clamp(1, 5);

  // serverTimestamp() pode chegar nulo em escritas locais ainda não confirmadas.
  static DateTime _toDate(Object? v) =>
      v is Timestamp ? v.toDate() : DateTime.now();
}
