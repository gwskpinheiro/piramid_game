import 'package:equatable/equatable.dart';

/// Notas (1 a 5) dos 15 critérios de popularidade.
class CriteriosPopularidade extends Equatable {
  final int resenha;
  final int presencaVip;
  final int aura;
  final int modoParceiro;
  final int carisma;
  final int humorMilhoes;
  final int energiaGrupo;
  final int criatividadeCaotica;
  final int modoAtleta;
  final int talentopalco;
  final int dripEscolar;
  final int coracaoDorama;
  final int queridinhoProf;
  final int cerebroTurbo;
  final int caosControlado;

  const CriteriosPopularidade({
    this.resenha = 1, this.presencaVip = 1, this.aura = 1,
    this.modoParceiro = 1, this.carisma = 1, this.humorMilhoes = 1,
    this.energiaGrupo = 1, this.criatividadeCaotica = 1, this.modoAtleta = 1,
    this.talentopalco = 1, this.dripEscolar = 1, this.coracaoDorama = 1,
    this.queridinhoProf = 1, this.cerebroTurbo = 1, this.caosControlado = 1,
  });

  int get nivelLenda =>
      resenha + presencaVip + aura + modoParceiro + carisma +
      humorMilhoes + energiaGrupo + criatividadeCaotica + modoAtleta +
      talentopalco + dripEscolar + coracaoDorama + queridinhoProf +
      cerebroTurbo + caosControlado;

  CriteriosPopularidade copyWith({
    int? resenha, int? presencaVip, int? aura, int? modoParceiro,
    int? carisma, int? humorMilhoes, int? energiaGrupo,
    int? criatividadeCaotica, int? modoAtleta, int? talentopalco,
    int? dripEscolar, int? coracaoDorama, int? queridinhoProf,
    int? cerebroTurbo, int? caosControlado,
  }) {
    return CriteriosPopularidade(
      resenha: resenha ?? this.resenha,
      presencaVip: presencaVip ?? this.presencaVip,
      aura: aura ?? this.aura,
      modoParceiro: modoParceiro ?? this.modoParceiro,
      carisma: carisma ?? this.carisma,
      humorMilhoes: humorMilhoes ?? this.humorMilhoes,
      energiaGrupo: energiaGrupo ?? this.energiaGrupo,
      criatividadeCaotica: criatividadeCaotica ?? this.criatividadeCaotica,
      modoAtleta: modoAtleta ?? this.modoAtleta,
      talentopalco: talentopalco ?? this.talentopalco,
      dripEscolar: dripEscolar ?? this.dripEscolar,
      coracaoDorama: coracaoDorama ?? this.coracaoDorama,
      queridinhoProf: queridinhoProf ?? this.queridinhoProf,
      cerebroTurbo: cerebroTurbo ?? this.cerebroTurbo,
      caosControlado: caosControlado ?? this.caosControlado,
    );
  }

  Map<String, dynamic> toMap() => {
    'resenha': resenha, 'presencaVip': presencaVip, 'aura': aura,
    'modoParceiro': modoParceiro, 'carisma': carisma,
    'humorMilhoes': humorMilhoes, 'energiaGrupo': energiaGrupo,
    'criatividadeCaotica': criatividadeCaotica, 'modoAtleta': modoAtleta,
    'talentopalco': talentopalco, 'dripEscolar': dripEscolar,
    'coracaoDorama': coracaoDorama, 'queridinhoProf': queridinhoProf,
    'cerebroTurbo': cerebroTurbo, 'caosControlado': caosControlado,
  };

  factory CriteriosPopularidade.fromMap(Map<String, dynamic> map) =>
      CriteriosPopularidade(
        resenha: (map['resenha'] as int? ?? 1).clamp(1, 5),
        presencaVip: (map['presencaVip'] as int? ?? 1).clamp(1, 5),
        aura: (map['aura'] as int? ?? 1).clamp(1, 5),
        modoParceiro: (map['modoParceiro'] as int? ?? 1).clamp(1, 5),
        carisma: (map['carisma'] as int? ?? 1).clamp(1, 5),
        humorMilhoes: (map['humorMilhoes'] as int? ?? 1).clamp(1, 5),
        energiaGrupo: (map['energiaGrupo'] as int? ?? 1).clamp(1, 5),
        criatividadeCaotica: (map['criatividadeCaotica'] as int? ?? 1).clamp(1, 5),
        modoAtleta: (map['modoAtleta'] as int? ?? 1).clamp(1, 5),
        talentopalco: (map['talentopalco'] as int? ?? 1).clamp(1, 5),
        dripEscolar: (map['dripEscolar'] as int? ?? 1).clamp(1, 5),
        coracaoDorama: (map['coracaoDorama'] as int? ?? 1).clamp(1, 5),
        queridinhoProf: (map['queridinhoProf'] as int? ?? 1).clamp(1, 5),
        cerebroTurbo: (map['cerebroTurbo'] as int? ?? 1).clamp(1, 5),
        caosControlado: (map['caosControlado'] as int? ?? 1).clamp(1, 5),
      );

  @override
  List<Object?> get props => [
    resenha, presencaVip, aura, modoParceiro, carisma,
    humorMilhoes, energiaGrupo, criatividadeCaotica, modoAtleta,
    talentopalco, dripEscolar, coracaoDorama, queridinhoProf,
    cerebroTurbo, caosControlado,
  ];
}

const listaCriterios = [
  ('Resenha', 'Mede o quanto o aluno anima a turma e contribui para o ambiente descontraído.'),
  ('Presença VIP', 'Avalia o quanto o aluno é lembrado e reconhecido pelos colegas.'),
  ('Aura', 'Representa a energia geral: presença, estilo e impacto no ambiente.'),
  ('Modo Parceiro', 'Mede o quanto o aluno ajuda os colegas e demonstra espírito de parceria.'),
  ('Carisma Natural', 'Avalia a facilidade para socializar e criar boas relações.'),
  ('Humor de Milhões', 'Representa a contribuição com bom humor e momentos divertidos.'),
  ('Energia de Grupo', 'Mede a participação em trabalhos, eventos e atividades coletivas.'),
  ('Criatividade Caótica', 'Avalia a capacidade de ter ideias diferentes e soluções inesperadas.'),
  ('Modo Atleta', 'Representa a aptidão esportiva e o espírito competitivo saudável.'),
  ('Talento de Palco', 'Mede a aptidão artística: música, dança, canto ou apresentações.'),
  ('Drip Escolar', 'Avalia o estilo pessoal: roupas, tênis, cabelo e presença visual.'),
  ('Coração de Dorama', 'Representa o carisma afetivo e a gentileza com os colegas.'),
  ('Queridinho dos Professores', 'Mede a boa relação com professores: respeito e responsabilidade.'),
  ('Cérebro Turbo', 'Avalia o desempenho nos estudos e a facilidade de aprender.'),
  ('Caos Controlado', 'Mede o quanto é zoeiro e imprevisível, mas dentro dos limites saudáveis.'),
];


/// Avaliação de uma pessoa ([pessoaId]) feita por um usuário ([avaliadorUid]).
/// Cada usuário possui no máximo uma avaliação por pessoa: o [id] é sempre
/// `pessoaId_avaliadorUid` (ver [gerarId]).
class Avaliacao extends Equatable {
  final String id;
  final String pessoaId;
  final String avaliadorUid;
  final CriteriosPopularidade criterios;
  final DateTime createdAt;
  /// Data da última gravação (criação ou alteração) da avaliação.
  final DateTime dataAvaliacao;

  const Avaliacao({
    required this.id, required this.pessoaId, required this.avaliadorUid,
    required this.criterios, required this.createdAt, required this.dataAvaliacao,
  });

  static String gerarId(String pessoaId, String avaliadorUid) =>
      '${pessoaId}_$avaliadorUid';

  /// Pontuação total (15 a 75).
  int get nivelLenda => criterios.nivelLenda;

  Avaliacao copyWith({
    String? id, String? pessoaId, String? avaliadorUid,
    CriteriosPopularidade? criterios, DateTime? createdAt, DateTime? dataAvaliacao,
  }) {
    return Avaliacao(
      id: id ?? this.id, pessoaId: pessoaId ?? this.pessoaId,
      avaliadorUid: avaliadorUid ?? this.avaliadorUid,
      criterios: criterios ?? this.criterios,
      createdAt: createdAt ?? this.createdAt,
      dataAvaliacao: dataAvaliacao ?? this.dataAvaliacao,
    );
  }

  @override
  List<Object?> get props =>
      [id, pessoaId, avaliadorUid, criterios, createdAt, dataAvaliacao];
}

/// Resultado da verificação de quem pode avaliar uma pessoa.
enum PermissaoAvaliacao {
  /// Conta vinculada e a pessoa não é o próprio usuário.
  permitida,
  /// Conta ainda sem vínculo administrativo com uma pessoa cadastrada.
  semVinculo,
  /// A pessoa é o próprio usuário (autoavaliação).
  autoavaliacao,
}
