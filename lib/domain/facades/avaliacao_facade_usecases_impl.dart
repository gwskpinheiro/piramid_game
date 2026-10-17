import '../../core/typedefs/types_defs.dart';
import '../usecases/avaliacao_usecases_interfaces.dart';
import 'avaliacao_facade_usecases_interface.dart';

final class AvaliacaoFacadeUseCasesImpl implements IAvaliacaoFacadeUseCases {
  final IVerificarAutoavaliacaoUseCase _verificar;
  final IConsultarAvaliacaoUseCase _consultar;
  final IRegistrarAvaliacaoUseCase _registrar;
  final IAlterarAvaliacaoUseCase _alterar;

  AvaliacaoFacadeUseCasesImpl({
    required IVerificarAutoavaliacaoUseCase verificar,
    required IConsultarAvaliacaoUseCase consultar,
    required IRegistrarAvaliacaoUseCase registrar,
    required IAlterarAvaliacaoUseCase alterar,
  })  : _verificar = verificar, _consultar = consultar,
        _registrar = registrar, _alterar = alterar;

  @override Future<PermissaoAvaliacaoResult> verificarAutoavaliacao(PessoaIdParams params) => _verificar(params);
  @override Future<AvaliacaoOpcionalResult> consultarAvaliacao(PessoaIdParams params) => _consultar(params);
  @override Future<AvaliacaoResult> avaliar(AvaliarParams params) => _registrar(params);
  @override Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params) => _alterar(params);
}
