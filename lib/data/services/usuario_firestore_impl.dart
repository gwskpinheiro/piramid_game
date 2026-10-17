import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';
import 'usuario_remote_storage_interface.dart';

/// Coleção `usuarios`: um documento por conta (id = uid), com o perfil
/// gravado pelo próprio usuário e o vínculo `pessoaId` gravado somente
/// pelo administrador (Firebase Console). As regras do Firestore impedem
/// que o cliente crie, altere ou remova `pessoaId`.
final class UsuarioFirestoreService implements IUsuarioRemoteStorage {
  static const String _colecao = 'usuarios';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection(_colecao).doc(uid);

  @override
  Future<VoidResult> salvarPerfil(Usuario usuario) async {
    try {
      // merge: preserva o pessoaId definido pelo administrador.
      await _doc(usuario.uid).set({
        'nome': usuario.nome ?? '',
        'email': usuario.email ?? '',
        'foto': usuario.fotoUrl ?? '',
        'provider': usuario.provider,
        'ultimoAcesso': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Success(null);
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure('Não foi possível salvar o perfil (${e.code}).'));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<VinculoResult> obterPessoaVinculada(String uid) async {
    try {
      final snap = await _doc(uid).get();
      final pessoaId = snap.data()?['pessoaId'];
      return Success(pessoaId is String && pessoaId.isNotEmpty ? pessoaId : null);
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(e.code == 'unavailable'
          ? 'Servidor indisponível. Verifique sua conexão.'
          : 'Não foi possível verificar o vínculo da sua conta.'));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }
}
