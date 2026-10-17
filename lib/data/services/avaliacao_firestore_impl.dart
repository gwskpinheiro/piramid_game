import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';
import 'avaliacao_firestore_mapper.dart';
import 'avaliacao_remote_storage_interface.dart';

/// Coleção `avaliacoes`: id determinístico `pessoaId_avaliadorUid`, garantindo
/// uma única avaliação ativa por usuário e pessoa. As regras do Firestore
/// validam notas, total, vínculo do avaliador e bloqueiam autoavaliação.
final class AvaliacaoFirestoreService implements IAvaliacaoRemoteStorage {
  static const String _colecao = 'avaliacoes';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(_colecao);

  @override
  Future<AvaliacaoResult> registrarAvaliacao(Avaliacao avaliacao) async {
    try {
      await _col.doc(avaliacao.id).set({
        'avaliadorUid': avaliacao.avaliadorUid,
        'pessoaId': avaliacao.pessoaId,
        ...AvaliacaoFirestoreMapper.notas(avaliacao.criterios),
        'createdAt': FieldValue.serverTimestamp(),
        'dataAvaliacao': FieldValue.serverTimestamp(),
      });
      return Success(avaliacao);
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e, 'registrar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<AvaliacaoResult> alterarAvaliacao(Avaliacao avaliacao) async {
    try {
      // update(): avaliadorUid, pessoaId e createdAt permanecem intactos.
      await _col.doc(avaliacao.id).update({
        ...AvaliacaoFirestoreMapper.notas(avaliacao.criterios),
        'dataAvaliacao': FieldValue.serverTimestamp(),
      });
      return Success(avaliacao);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return r.Error(NotFoundFailure('Avaliação não encontrada para alterar.'));
      }
      return r.Error(RemoteFailure(_mensagem(e, 'alterar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<AvaliacaoOpcionalResult> consultarAvaliacao(String pessoaId, String avaliadorUid) async {
    try {
      final doc = await _col.doc(Avaliacao.gerarId(pessoaId, avaliadorUid)).get();
      final data = doc.data();
      if (!doc.exists || data == null) return const Success(null);
      return Success(AvaliacaoFirestoreMapper.fromFirestore(doc.id, data));
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e, 'carregar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<ListAvaliacaoResult> obterAvaliacoesDoAvaliador(String avaliadorUid) =>
      _listar(_col.where('avaliadorUid', isEqualTo: avaliadorUid));

  @override
  Future<ListAvaliacaoResult> obterTodasAvaliacoes() => _listar(_col);

  Future<ListAvaliacaoResult> _listar(Query<Map<String, dynamic>> consulta) async {
    try {
      final snap = await consulta.get();
      return Success(snap.docs
          .map((d) => AvaliacaoFirestoreMapper.fromFirestore(d.id, d.data()))
          .toList());
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(e.code == 'permission-denied'
          ? 'Sem permissão para ler as avaliações. Verifique se você está logado.'
          : _mensagem(e, 'carregar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  String _mensagem(FirebaseException e, String acao) => switch (e.code) {
        'permission-denied' =>
          'Avaliação recusada pelo servidor. Verifique se sua conta está vinculada '
              'e se você não está avaliando a si mesmo.',
        'unavailable' || 'deadline-exceeded' =>
          'Servidor indisponível. Verifique sua conexão e tente novamente.',
        'unauthenticated' => 'Sua sessão expirou. Entre novamente.',
        _ => 'Não foi possível $acao a avaliação. Tente novamente.',
      };
}
