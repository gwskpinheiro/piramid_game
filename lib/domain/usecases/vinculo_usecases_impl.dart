import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../../data/repositories/usuario_repository_interface.dart';
import '../../data/repositories/vinculo_repository_interface.dart';
import 'pessoa_usecases_impl.dart' show validarDadosPessoa;
import 'vinculo_usecases_interfaces.dart';

final class ObterVinculoUseCaseImpl implements IObterVinculoUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  ObterVinculoUseCaseImpl({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository, _usuarioRepository = usuarioRepository;

  @override
  Future<VinculoResult> call(NoParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return r.Error(AuthFailure('Nenhum usuário autenticado.'));
    return _usuarioRepository.obterPessoaVinculada(usuario.uid);
  }
}

final class ObterPessoasDisponiveisUseCaseImpl implements IObterPessoasDisponiveisUseCase {
  final IPessoaRepository _pessoaRepository;
  final IVinculoRepository _vinculoRepository;

  ObterPessoasDisponiveisUseCaseImpl({
    required IPessoaRepository pessoaRepository,
    required IVinculoRepository vinculoRepository,
  })  : _pessoaRepository = pessoaRepository, _vinculoRepository = vinculoRepository;

  @override
  Future<ListPessoaResult> call(NoParams params) async {
    final (pessoas, vinculadas) =
        await (_pessoaRepository.obterTodasPessoas(), _vinculoRepository.obterPessoasVinculadas()).wait;
    return pessoas.fold(
      onSuccess: (lista) => vinculadas.fold(
        onSuccess: (ids) => Success(lista.where((p) => !ids.contains(p.id)).toList()),
        onFailure: (f) => r.Error(f),
      ),
      onFailure: (f) => r.Error(f),
    );
  }
}

/// Regra comum: só vincula se a conta estiver autenticada e ainda sem vínculo.
Future<r.Result<String, Failure>> _uidSemVinculo(
  IAuthRepository authRepository,
  IUsuarioRepository usuarioRepository,
) async {
  final usuario = authRepository.usuarioAtual;
  if (usuario == null) return r.Error(AuthFailure('Entre na sua conta para identificar seu perfil.'));
  final atual = await usuarioRepository.obterPessoaVinculada(usuario.uid);
  return atual.fold(
    onSuccess: (pessoaId) => pessoaId == null
        ? Success(usuario.uid)
        : r.Error(AuthFailure('Sua conta já está vinculada a um perfil e o vínculo não pode ser alterado.')),
    onFailure: (f) => r.Error(f),
  );
}

final class VincularPessoaExistenteUseCaseImpl implements IVincularPessoaExistenteUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;
  final IVinculoRepository _vinculoRepository;

  VincularPessoaExistenteUseCaseImpl({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
    required IVinculoRepository vinculoRepository,
  })  : _authRepository = authRepository, _usuarioRepository = usuarioRepository,
        _vinculoRepository = vinculoRepository;

  @override
  Future<VinculoResult> call(PessoaIdParams params) async {
    if (params.id.isEmpty) return r.Error(InputFailure('Selecione um perfil.'));
    final uid = await _uidSemVinculo(_authRepository, _usuarioRepository);
    return uid.fold(
      onSuccess: (u) async {
        final result = await _vinculoRepository.vincularPessoaExistente(u, params.id);
        return result.fold(onSuccess: (_) => Success(params.id), onFailure: (f) => r.Error(f));
      },
      onFailure: (f) async => r.Error(f),
    );
  }
}

final class CadastrarPerfilEVincularUseCaseImpl implements ICadastrarPerfilEVincularUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;
  final IVinculoRepository _vinculoRepository;

  CadastrarPerfilEVincularUseCaseImpl({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
    required IVinculoRepository vinculoRepository,
  })  : _authRepository = authRepository, _usuarioRepository = usuarioRepository,
        _vinculoRepository = vinculoRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final erro = validarDadosPessoa(params.pessoa);
    if (erro != null) return r.Error(InputFailure(erro));
    final uid = await _uidSemVinculo(_authRepository, _usuarioRepository);
    return uid.fold(
      onSuccess: (u) {
        final now = DateTime.now();
        return _vinculoRepository.cadastrarPerfilEVincular(u, params.pessoa.copyWith(
          nome: params.pessoa.nome.trim(),
          apelido: params.pessoa.apelido.trim(),
          criadoPor: u,
          createdAt: now,
          updatedAt: now,
        ));
      },
      onFailure: (f) async => r.Error(f),
    );
  }
}
