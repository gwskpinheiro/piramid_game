import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';
import '../models/usuario_entity.dart';

abstract interface class IObservarUsuarioUseCase
    implements IStreamUseCase<Usuario?, NoParams> {}

abstract interface class IEntrarComEmailUseCase
    implements IUseCase<UsuarioResult, CredenciaisParams> {}

abstract interface class ICadastrarUsuarioUseCase
    implements IUseCase<UsuarioResult, CredenciaisParams> {}

abstract interface class IEntrarComGoogleUseCase
    implements IUseCase<UsuarioResult, NoParams> {}

abstract interface class ISairUseCase implements IUseCase<VoidResult, NoParams> {}

/// Grava/atualiza o perfil do usuário autenticado em `usuarios/{uid}`.
abstract interface class IRegistrarPerfilUsuarioUseCase
    implements IUseCase<VoidResult, NoParams> {}
