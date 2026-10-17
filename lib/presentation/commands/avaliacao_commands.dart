import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/models/avaliacao_entity.dart';

final class VerificarAutoavaliacaoCommand
    extends ParameterizedCommand<PermissaoAvaliacao, Failure, PessoaIdParams> {
  final IAvaliacaoFacadeUseCases _facade;
  VerificarAutoavaliacaoCommand(this._facade);
  @override
  Future<PermissaoAvaliacaoResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) return r.Error(InputFailure('ID inválido.'));
    return _facade.verificarAutoavaliacao(parameter!);
  }
}

final class ConsultarAvaliacaoCommand
    extends ParameterizedCommand<Avaliacao?, Failure, PessoaIdParams> {
  final IAvaliacaoFacadeUseCases _facade;
  ConsultarAvaliacaoCommand(this._facade);
  @override
  Future<AvaliacaoOpcionalResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) return r.Error(InputFailure('ID inválido.'));
    return _facade.consultarAvaliacao(parameter!);
  }
}

final class AvaliarPessoaCommand extends ParameterizedCommand<Avaliacao, Failure, AvaliarParams> {
  final IAvaliacaoFacadeUseCases _facade;
  AvaliarPessoaCommand(this._facade);
  @override
  Future<AvaliacaoResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.avaliar(parameter!);
  }
}

final class AlterarAvaliacaoCommand extends ParameterizedCommand<Avaliacao, Failure, AvaliarParams> {
  final IAvaliacaoFacadeUseCases _facade;
  AlterarAvaliacaoCommand(this._facade);
  @override
  Future<AvaliacaoResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.alterarAvaliacao(parameter!);
  }
}
