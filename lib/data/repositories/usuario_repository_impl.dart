import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';
import '../services/usuario_remote_storage_interface.dart';
import 'usuario_repository_interface.dart';

final class UsuarioRepositoryImpl implements IUsuarioRepository {
  final IUsuarioRemoteStorage _remoteStorage;

  UsuarioRepositoryImpl({required IUsuarioRemoteStorage remoteStorage})
      : _remoteStorage = remoteStorage;

  @override
  Future<VoidResult> salvarPerfil(Usuario usuario) => _remoteStorage.salvarPerfil(usuario);
  @override
  Future<VinculoResult> obterPessoaVinculada(String uid) =>
      _remoteStorage.obterPessoaVinculada(uid);
}
