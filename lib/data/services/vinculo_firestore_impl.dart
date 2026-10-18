import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';
import 'pessoa_firestore_mapper.dart';
import 'vinculo_remote_storage_interface.dart';

/// Vínculo conta ↔ pessoa no Firestore.
///
/// - `vinculos/{pessoaId}` = `{ uid, criadoEm }`: o id do documento é a própria
///   pessoa, então só pode existir um vínculo por pessoa (unicidade).
/// - `usuarios/{uid}.pessoaId`: o perfil da conta (gravado uma única vez).
///
/// Os dois documentos são gravados no mesmo WriteBatch: ou ambos são gravados,
/// ou nenhum. Se duas contas escolherem a mesma pessoa ao mesmo tempo, as
/// regras recusam o lote que chegar depois (o vínculo já existe).
final class VinculoFirestoreService implements IVinculoRemoteStorage {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vinculos => _db.collection('vinculos');
  CollectionReference<Map<String, dynamic>> get _usuarios => _db.collection('usuarios');
  CollectionReference<Map<String, dynamic>> get _pessoas => _db.collection('pessoas');

  @override
  Future<IdsResult> obterPessoasVinculadas() async {
    try {
      final snap = await _vinculos.get();
      return Success({for (final d in snap.docs) d.id});
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e)));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<VoidResult> vincularPessoaExistente(String uid, String pessoaId) async {
    try {
      final lote = _db.batch();
      _adicionarVinculo(lote, uid, pessoaId);
      await lote.commit();
      return const Success(null);
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e)));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<PessoaResult> cadastrarPerfilEVincular(String uid, Pessoa pessoa) async {
    try {
      final ref = _pessoas.doc(); // id gerado pelo Firestore
      final lote = _db.batch();
      lote.set(ref, {
        ...PessoaFirestoreMapper.camposEditaveis(pessoa),
        'criadoPor': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _adicionarVinculo(lote, uid, ref.id);
      await lote.commit();
      return Success(pessoa.copyWith(id: ref.id, criadoPor: uid));
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e)));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  void _adicionarVinculo(WriteBatch lote, String uid, String pessoaId) {
    lote.set(_vinculos.doc(pessoaId), {
      'uid': uid,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    // merge: preserva os dados de perfil já gravados em usuarios/{uid}.
    lote.set(_usuarios.doc(uid), {'pessoaId': pessoaId}, SetOptions(merge: true));
  }

  String _mensagem(FirebaseException e) => switch (e.code) {
        'permission-denied' =>
          'Não foi possível vincular: este perfil acabou de ser vinculado a outra '
              'conta, ou sua conta já possui um vínculo.',
        'unavailable' || 'deadline-exceeded' =>
          'Servidor indisponível. Verifique sua conexão e tente novamente.',
        'unauthenticated' => 'Sua sessão expirou. Entre novamente.',
        _ => 'Não foi possível concluir o vínculo. Tente novamente.',
      };
}
