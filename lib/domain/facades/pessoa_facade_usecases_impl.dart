import '../../core/typedefs/types_defs.dart';
import '../usecases/pessoa_usecases_interfaces.dart';
import 'pessoa_facade_usecases_interface.dart';

final class PessoaFacadeUseCasesImpl implements IPessoaFacadeUseCases {
  final ICadastrarPessoaUseCase _cadastrar;
  final IObterTodasPessoasUseCase _obterTodas;
  final IObterPessoaPorIdUseCase _obterPorId;
  final IAtualizarPessoaUseCase _atualizar;
  final IDeletarPessoaUseCase _deletar;

  PessoaFacadeUseCasesImpl({
    required ICadastrarPessoaUseCase cadastrar,
    required IObterTodasPessoasUseCase obterTodas,
    required IObterPessoaPorIdUseCase obterPorId,
    required IAtualizarPessoaUseCase atualizar,
    required IDeletarPessoaUseCase deletar,
  })  : _cadastrar = cadastrar, _obterTodas = obterTodas, _obterPorId = obterPorId,
        _atualizar = atualizar, _deletar = deletar;

  @override Future<PessoaResult> cadastrarPessoa(PessoaParams params) => _cadastrar(params);
  @override Future<ListPessoaResult> obterTodasPessoas(NoParams params) => _obterTodas(params);
  @override Future<PessoaResult> obterPessoaPorId(PessoaIdParams params) => _obterPorId(params);
  @override Future<PessoaResult> atualizarPessoa(PessoaParams params) => _atualizar(params);
  @override Future<VoidResult> deletarPessoa(PessoaIdParams params) => _deletar(params);
}
