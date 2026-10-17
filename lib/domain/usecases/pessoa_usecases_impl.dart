import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/pessoa_entity.dart';
import 'pessoa_usecases_interfaces.dart';

/// Valida os dados cadastrais; retorna a mensagem de erro ou null.
String? _validarPessoa(Pessoa p) {
  if (p.nome.trim().isEmpty) return 'O nome é obrigatório.';
  if (p.nome.trim().length > 100) return 'O nome deve ter no máximo 100 caracteres.';
  if (p.apelido.trim().length > 60) return 'O apelido deve ter no máximo 60 caracteres.';
  if (p.dataNascimento.isAfter(DateTime.now())) {
    return 'A data de nascimento não pode estar no futuro.';
  }
  return null;
}

final class CadastrarPessoaUseCaseImpl implements ICadastrarPessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _authRepository;

  CadastrarPessoaUseCaseImpl({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository, _authRepository = authRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return r.Error(AuthFailure('Entre na sua conta para cadastrar.'));

    final erro = _validarPessoa(params.pessoa);
    if (erro != null) return r.Error(InputFailure(erro));

    final now = DateTime.now();
    final nova = params.pessoa.copyWith(
      nome: params.pessoa.nome.trim(),
      apelido: params.pessoa.apelido.trim(),
      criadoPor: usuario.uid, // registra quem cadastrou
      createdAt: now,
      updatedAt: now,
    );
    return _repository.salvarPessoa(nova);
  }
}

final class ObterTodasPessoasUseCaseImpl implements IObterTodasPessoasUseCase {
  final IPessoaRepository _repository;
  ObterTodasPessoasUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<ListPessoaResult> call(NoParams params) => _repository.obterTodasPessoas();
}

final class ObterPessoaPorIdUseCaseImpl implements IObterPessoaPorIdUseCase {
  final IPessoaRepository _repository;
  ObterPessoaPorIdUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<PessoaResult> call(PessoaIdParams params) =>
      _repository.obterPessoaPorId(params.id);
}

final class AtualizarPessoaUseCaseImpl implements IAtualizarPessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _authRepository;

  AtualizarPessoaUseCaseImpl({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository, _authRepository = authRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final pessoa = params.pessoa;
    if (_authRepository.usuarioAtual?.uid != pessoa.criadoPor) {
      return r.Error(AuthFailure('Apenas quem cadastrou esta pessoa pode editá-la.'));
    }
    final erro = _validarPessoa(pessoa);
    if (erro != null) return r.Error(InputFailure(erro));

    return _repository.atualizarPessoa(pessoa.copyWith(
      nome: pessoa.nome.trim(),
      apelido: pessoa.apelido.trim(),
      updatedAt: DateTime.now(),
    ));
  }
}

final class DeletarPessoaUseCaseImpl implements IDeletarPessoaUseCase {
  final IPessoaRepository _repository;
  DeletarPessoaUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  // A restrição ao criador é garantida pelas regras do Firestore.
  @override
  Future<VoidResult> call(PessoaIdParams params) =>
      _repository.deletarPessoa(params.id);
}
