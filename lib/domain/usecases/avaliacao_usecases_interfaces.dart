import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Verifica se o usuário autenticado pode avaliar a pessoa (vínculo + autoavaliação).
abstract interface class IVerificarAutoavaliacaoUseCase
    implements IUseCase<PermissaoAvaliacaoResult, PessoaIdParams> {}

/// Avaliação da pessoa feita pelo usuário autenticado (null se ainda não avaliou).
abstract interface class IConsultarAvaliacaoUseCase
    implements IUseCase<AvaliacaoOpcionalResult, PessoaIdParams> {}

abstract interface class IRegistrarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

abstract interface class IAlterarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}
