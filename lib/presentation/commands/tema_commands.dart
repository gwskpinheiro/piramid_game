import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/tema_facade_usecases_interface.dart';
import '../../domain/models/preferencia_tema.dart';

final class CarregarTemaCommand extends ParameterizedCommand<PreferenciaTema, Failure, NoParams> {
  final ITemaFacadeUseCases _facade;
  CarregarTemaCommand(this._facade);
  @override
  Future<TemaResult> execute() => _facade.obterTema(());
}

final class AlterarTemaCommand extends ParameterizedCommand<void, Failure, TemaParams> {
  final ITemaFacadeUseCases _facade;
  AlterarTemaCommand(this._facade);
  @override
  Future<VoidResult> execute() async {
    if (parameter == null) return r.Error(InputFailure('Parâmetro nulo.'));
    return _facade.alterarTema(parameter!);
  }
}
