import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/usuario_entity.dart';

class AuthStateViewModel {
  final usuario = signal<Usuario?>(null);
  final mensagem = signal<String?>(null);
  final isLoading = signal<bool>(false);

  late final isAutenticado = computed<bool>(() => usuario.value != null);

  void limparMensagem() => mensagem.value = null;
  void setMensagem(String msg) => mensagem.value = msg;
  void setLoading(bool value) => isLoading.value = value;
  void setUsuario(Usuario? value) => usuario.value = value;
}
