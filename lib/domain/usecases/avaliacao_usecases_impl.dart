import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/usuario_repository_interface.dart';
import '../models/avaliacao_entity.dart';
import 'avaliacao_usecases_interfaces.dart';

final class VerificarAutoavaliacaoUseCaseImpl implements IVerificarAutoavaliacaoUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  VerificarAutoavaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository, _usuarioRepository = usuarioRepository;

  @override
  Future<PermissaoAvaliacaoResult> call(PessoaIdParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return r.Error(AuthFailure('Entre na sua conta para avaliar.'));

    final vinculo = await _usuarioRepository.obterPessoaVinculada(usuario.uid);
    return vinculo.fold(
      onSuccess: (pessoaVinculada) {
        if (pessoaVinculada == null) return const Success(PermissaoAvaliacao.semVinculo);
        if (pessoaVinculada == params.id) return const Success(PermissaoAvaliacao.autoavaliacao);
        return const Success(PermissaoAvaliacao.permitida);
      },
      onFailure: (f) => r.Error(f),
    );
  }
}

final class ConsultarAvaliacaoUseCaseImpl implements IConsultarAvaliacaoUseCase {
  final IAuthRepository _authRepository;
  final IAvaliacaoRepository _repository;

  ConsultarAvaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository repository,
  })  : _authRepository = authRepository, _repository = repository;

  @override
  Future<AvaliacaoOpcionalResult> call(PessoaIdParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return r.Error(AuthFailure('Entre na sua conta.'));
    return _repository.consultarAvaliacao(params.id, usuario.uid);
  }
}

/// Regras comuns a registrar/alterar: login, notas de 1 a 5, vínculo e
/// autoavaliação. As mesmas regras são reaplicadas no servidor (firestore.rules).
Future<r.Result<Avaliacao, Failure>> _prepararAvaliacao(
  AvaliarParams params,
  IAuthRepository authRepository,
  IVerificarAutoavaliacaoUseCase verificar,
) async {
  final usuario = authRepository.usuarioAtual;
  if (usuario == null) return r.Error(AuthFailure('Entre na sua conta para avaliar.'));

  final notasValidas = params.criterios.props
      .every((n) => n is int && n >= 1 && n <= 5);
  if (!notasValidas || params.criterios.props.length != 15) {
    return r.Error(InputFailure('Cada critério deve ter nota entre 1 e 5 estrelas.'));
  }

  final permissao = await verificar((id: params.pessoaId));
  return permissao.fold(
    onSuccess: (p) => switch (p) {
      PermissaoAvaliacao.semVinculo => r.Error(AuthFailure(
          'Sua conta ainda não está vinculada ao seu próprio perfil. '
          'Conclua a identificação do perfil para poder avaliar.')),
      PermissaoAvaliacao.autoavaliacao =>
        r.Error(AuthFailure('Você não pode avaliar a si mesmo.')),
      PermissaoAvaliacao.permitida => Success(Avaliacao(
          id: Avaliacao.gerarId(params.pessoaId, usuario.uid),
          pessoaId: params.pessoaId,
          avaliadorUid: usuario.uid,
          criterios: params.criterios,
          createdAt: DateTime.now(),
          dataAvaliacao: DateTime.now(),
        )),
    },
    onFailure: (f) => r.Error(f),
  );
}

final class RegistrarAvaliacaoUseCaseImpl implements IRegistrarAvaliacaoUseCase {
  final IAuthRepository _authRepository;
  final IAvaliacaoRepository _repository;
  final IVerificarAutoavaliacaoUseCase _verificar;

  RegistrarAvaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository repository,
    required IVerificarAutoavaliacaoUseCase verificar,
  })  : _authRepository = authRepository, _repository = repository, _verificar = verificar;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final preparada = await _prepararAvaliacao(params, _authRepository, _verificar);
    return preparada.fold(
      onSuccess: _repository.registrarAvaliacao,
      onFailure: (f) async => r.Error(f),
    );
  }
}

final class AlterarAvaliacaoUseCaseImpl implements IAlterarAvaliacaoUseCase {
  final IAuthRepository _authRepository;
  final IAvaliacaoRepository _repository;
  final IVerificarAutoavaliacaoUseCase _verificar;

  AlterarAvaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository repository,
    required IVerificarAutoavaliacaoUseCase verificar,
  })  : _authRepository = authRepository, _repository = repository, _verificar = verificar;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final preparada = await _prepararAvaliacao(params, _authRepository, _verificar);
    return preparada.fold(
      onSuccess: _repository.alterarAvaliacao,
      onFailure: (f) async => r.Error(f),
    );
  }
}
