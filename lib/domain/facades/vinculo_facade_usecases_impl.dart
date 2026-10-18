import '../../core/typedefs/types_defs.dart';
import '../usecases/vinculo_usecases_interfaces.dart';
import 'vinculo_facade_usecases_interface.dart';

final class VinculoFacadeUseCasesImpl implements IVinculoFacadeUseCases {
  final IObterVinculoUseCase _obter;
  final IObterPessoasDisponiveisUseCase _disponiveis;
  final IVincularPessoaExistenteUseCase _vincular;
  final ICadastrarPerfilEVincularUseCase _cadastrar;

  VinculoFacadeUseCasesImpl({
    required IObterVinculoUseCase obter,
    required IObterPessoasDisponiveisUseCase disponiveis,
    required IVincularPessoaExistenteUseCase vincular,
    required ICadastrarPerfilEVincularUseCase cadastrar,
  })  : _obter = obter, _disponiveis = disponiveis, _vincular = vincular, _cadastrar = cadastrar;

  @override Future<VinculoResult> obterVinculo(NoParams params) => _obter(params);
  @override Future<ListPessoaResult> obterPessoasDisponiveis(NoParams params) => _disponiveis(params);
  @override Future<VinculoResult> vincularPessoaExistente(PessoaIdParams params) => _vincular(params);
  @override Future<PessoaResult> cadastrarPerfilEVincular(PessoaParams params) => _cadastrar(params);
}
