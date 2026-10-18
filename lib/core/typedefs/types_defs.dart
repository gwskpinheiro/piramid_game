import 'package:flutter/material.dart';
import '../failure/failure.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../../domain/models/pessoa_entity.dart';
import '../../domain/models/preferencia_tema.dart';
import '../../domain/models/ranking_entity.dart';
import '../../domain/models/usuario_entity.dart';
import '../patterns/result.dart';

typedef VoidResult = Result<void, Failure>;
typedef PessoaResult = Result<Pessoa, Failure>;
typedef ListPessoaResult = Result<List<Pessoa>, Failure>;
typedef UsuarioResult = Result<Usuario, Failure>;
typedef AvaliacaoResult = Result<Avaliacao, Failure>;
typedef AvaliacaoOpcionalResult = Result<Avaliacao?, Failure>;
typedef VinculoResult = Result<String?, Failure>; // pessoaId vinculada ou null
typedef PermissaoAvaliacaoResult = Result<PermissaoAvaliacao, Failure>;
typedef ListAvaliacaoResult = Result<List<Avaliacao>, Failure>;
typedef RankingResult = Result<List<ItemRanking>, Failure>;
typedef TextoOpcionalResult = Result<String?, Failure>;
typedef IdsResult = Result<Set<String>, Failure>;
typedef TemaResult = Result<PreferenciaTema, Failure>;

typedef NoParams = ();
typedef PessoaIdParams = ({String id});
typedef PessoaParams = ({Pessoa pessoa});
typedef AvaliarParams = ({String pessoaId, CriteriosPopularidade criterios});
typedef CredenciaisParams = ({String email, String senha});
typedef TemaParams = ({PreferenciaTema tema});

typedef FormFieldControl = ({
  GlobalKey<FormFieldState> key,
  FocusNode focus,
  TextEditingController controller,
});
