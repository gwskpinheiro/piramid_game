import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/avaliacao_entity.dart';
import '../models/pessoa_entity.dart';
import '../models/ranking_entity.dart';
import 'ranking_calculadora.dart';
import 'ranking_usecases_interfaces.dart';

/// Busca pessoas e avaliações em paralelo e combina os dois resultados.
Future<RankingResult> _combinar(
  Future<ListPessoaResult> pessoas,
  Future<ListAvaliacaoResult> avaliacoes,
  List<ItemRanking> Function(List<Pessoa>, List<Avaliacao>) calcular,
) async {
  final (rp, ra) = await (pessoas, avaliacoes).wait;
  return rp.fold(
    onSuccess: (listaPessoas) => ra.fold(
      onSuccess: (listaAvaliacoes) => Success(calcular(listaPessoas, listaAvaliacoes)),
      onFailure: (f) => r.Error(f),
    ),
    onFailure: (f) => r.Error(f),
  );
}

final class CalcularRankingPessoalUseCaseImpl implements ICalcularRankingPessoalUseCase {
  final IAuthRepository _authRepository;
  final IPessoaRepository _pessoaRepository;
  final IAvaliacaoRepository _avaliacaoRepository;

  CalcularRankingPessoalUseCaseImpl({
    required IAuthRepository authRepository,
    required IPessoaRepository pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _authRepository = authRepository, _pessoaRepository = pessoaRepository,
        _avaliacaoRepository = avaliacaoRepository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return r.Error(AuthFailure('Entre na sua conta para ver seu ranking.'));
    return _combinar(
      _pessoaRepository.obterTodasPessoas(),
      _avaliacaoRepository.obterAvaliacoesDoAvaliador(usuario.uid),
      (pessoas, avaliacoes) => RankingCalculadora.pessoal(
        pessoas: pessoas, avaliacoes: avaliacoes, avaliadorUid: usuario.uid,
      ),
    );
  }
}

final class CalcularRankingGlobalUseCaseImpl implements ICalcularRankingGlobalUseCase {
  final IPessoaRepository _pessoaRepository;
  final IAvaliacaoRepository _avaliacaoRepository;

  CalcularRankingGlobalUseCaseImpl({
    required IPessoaRepository pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _pessoaRepository = pessoaRepository, _avaliacaoRepository = avaliacaoRepository;

  @override
  Future<RankingResult> call(NoParams params) => _combinar(
        _pessoaRepository.obterTodasPessoas(),
        _avaliacaoRepository.obterTodasAvaliacoes(),
        (pessoas, avaliacoes) =>
            RankingCalculadora.global(pessoas: pessoas, avaliacoes: avaliacoes),
      );
}
