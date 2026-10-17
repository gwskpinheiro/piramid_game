import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';
import 'pessoa_firestore_mapper.dart';
import 'pessoa_remote_storage_interface.dart';

/// Implementação de [IPessoaRemoteStorage] usando o Cloud Firestore.
///
/// Coleção `pessoas`: um documento por pessoa, com os dados cadastrais,
/// o uid de quem cadastrou (`criadoPor`) e as datas de controle
/// (`createdAt`/`updatedAt`, preenchidas pelo servidor).
final class PessoaFirestoreService implements IPessoaRemoteStorage {
  static const String _colecao = 'pessoas';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(_colecao);

  @override
  Future<PessoaResult> salvarPessoa(Pessoa pessoa) async {
    try {
      final ref = _col.doc(); // id gerado pelo Firestore
      await ref.set({
        ...PessoaFirestoreMapper.camposEditaveis(pessoa),
        'criadoPor': pessoa.criadoPor,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Success(pessoa.copyWith(id: ref.id));
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e, 'cadastrar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<ListPessoaResult> obterTodasPessoas() async {
    try {
      final snap = await _col.orderBy('nome').get();
      final pessoas = snap.docs
          .map((d) => PessoaFirestoreMapper.fromFirestore(d.id, d.data()))
          .toList();
      return Success(pessoas);
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e, 'carregar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<PessoaResult> obterPessoaPorId(String id) async {
    try {
      final doc = await _col.doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        return r.Error(NotFoundFailure('Pessoa não encontrada.'));
      }
      return Success(PessoaFirestoreMapper.fromFirestore(doc.id, data));
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e, 'carregar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<PessoaResult> atualizarPessoa(Pessoa pessoa) async {
    try {
      // update() altera só os campos enviados: criadoPor e createdAt
      // permanecem intactos, como exigem as regras de segurança.
      await _col.doc(pessoa.id).update({
        ...PessoaFirestoreMapper.camposEditaveis(pessoa),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Success(pessoa);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return r.Error(NotFoundFailure('Pessoa não encontrada para atualizar.'));
      }
      return r.Error(RemoteFailure(_mensagem(e, 'atualizar')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  @override
  Future<VoidResult> deletarPessoa(String id) async {
    try {
      await _col.doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return r.Error(RemoteFailure(_mensagem(e, 'remover')));
    } catch (_) {
      return r.Error(RemoteFailure());
    }
  }

  String _mensagem(FirebaseException e, String acao) => switch (e.code) {
        'permission-denied' => acao == 'carregar' || acao == 'cadastrar'
            ? 'Sem permissão para $acao. Verifique se você está logado.'
            : 'Sem permissão para $acao: apenas quem cadastrou a pessoa pode fazer isso.',
        'unavailable' || 'deadline-exceeded' =>
          'Servidor indisponível. Verifique sua conexão e tente novamente.',
        'unauthenticated' => 'Sua sessão expirou. Entre novamente.',
        _ => 'Não foi possível $acao a pessoa. Tente novamente.',
      };
}
