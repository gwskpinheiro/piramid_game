import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/usuario_entity.dart';

/// Executa [limpar] sempre que o usuário autenticado muda (logout ou login
/// com outra conta), para que dados de um usuário nunca fiquem visíveis para
/// outro. Retorna a função que encerra a observação.
void Function() aoTrocarUsuario(
  ReadonlySignal<Usuario?> usuario,
  void Function() limpar,
) {
  var uidAnterior = usuario.peek()?.uid;
  return effect(() {
    final uid = usuario.value?.uid;
    if (uid == uidAnterior) return;
    uidAnterior = uid;
    untracked(limpar);
  });
}
