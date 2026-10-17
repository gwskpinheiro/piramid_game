import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/models/pessoa_entity.dart';

final class ObterTodasPessoasCommand extends ParameterizedCommand<List<Pessoa>, Failure, NoParams> {
  final IPessoaFacadeUseCases _facade;
  ObterTodasPessoasCommand(this._facade);
  @override
  Future<ListPessoaResult> execute() => _facade.obterTodasPessoas(());
}

final class CadastrarPessoaCommand extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IPessoaFacadeUseCases _facade;
  CadastrarPessoaCommand(this._facade);
  @override
  Future<PessoaResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.cadastrarPessoa(parameter!);
  }
}

final class AtualizarPessoaCommand extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IPessoaFacadeUseCases _facade;
  AtualizarPessoaCommand(this._facade);
  @override
  Future<PessoaResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.atualizarPessoa(parameter!);
  }
}

final class DeletarPessoaCommand extends ParameterizedCommand<void, Failure, PessoaIdParams> {
  final IPessoaFacadeUseCases _facade;
  DeletarPessoaCommand(this._facade);
  @override
  Future<VoidResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) return r.Error(InputFailure('ID inválido.'));
    return _facade.deletarPessoa(parameter!);
  }
}

final class BuscarPessoaPorIdCommand extends ParameterizedCommand<Pessoa, Failure, PessoaIdParams> {
  final IPessoaFacadeUseCases _facade;
  BuscarPessoaPorIdCommand(this._facade);
  @override
  Future<PessoaResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) return r.Error(InputFailure('ID inválido.'));
    return _facade.obterPessoaPorId(parameter!);
  }
}
