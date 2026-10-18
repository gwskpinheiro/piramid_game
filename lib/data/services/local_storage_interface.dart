import '../../core/typedefs/types_defs.dart';

/// Armazenamento local simples (chave → texto) para preferências do app.
/// Não deve guardar senhas, credenciais nem os dados principais (Firestore).
abstract interface class ILocalStorageService {
  Future<TextoOpcionalResult> lerTexto(String chave);
  Future<VoidResult> salvarTexto(String chave, String valor);
}
