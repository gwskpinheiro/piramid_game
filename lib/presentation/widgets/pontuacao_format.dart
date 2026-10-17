import 'package:intl/intl.dart';

import '../../domain/models/ranking_entity.dart';

final _formato = NumberFormat('#0.#', 'pt_BR');

/// "58 pts" (pessoal) ou "64,8 pts" (média global, 1 casa decimal).
String formatarPontuacao(ItemRanking item) => '${_formato.format(item.pontuacao)} pts';

/// "1 avaliação" / "12 avaliações".
String formatarQuantidadeAvaliacoes(int n) => '$n ${n == 1 ? 'avaliação' : 'avaliações'}';
