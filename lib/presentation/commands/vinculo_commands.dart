import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/vinculo_facade_usecases_interface.dart';
import '../../domain/models/pessoa_entity.dart';

final class VerificarVinculoCommand extends ParameterizedCommand<String?, Failure, NoParams> {
  final IVinculoFacadeUseCases _facade;
  VerificarVinculoCommand(this._facade);
  @override
  Future<VinculoResult> execute() => _facade.obterVinculo(());
}

final class CarregarPessoasDisponiveisCommand
    extends ParameterizedCommand<List<Pessoa>, Failure, NoParams> {
  final IVinculoFacadeUseCases _facade;
  CarregarPessoasDisponiveisCommand(this._facade);
  @override
  Future<ListPessoaResult> execute() => _facade.obterPessoasDisponiveis(());
}

final class VincularPessoaCommand extends ParameterizedCommand<String?, Failure, PessoaIdParams> {
  final IVinculoFacadeUseCases _facade;
  VincularPessoaCommand(this._facade);
  @override
  Future<VinculoResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Selecione um perfil.'));
    return _facade.vincularPessoaExistente(parameter!);
  }
}

final class CadastrarPerfilEVincularCommand extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IVinculoFacadeUseCases _facade;
  CadastrarPerfilEVincularCommand(this._facade);
  @override
  Future<PessoaResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.cadastrarPerfilEVincular(parameter!);
  }
}
