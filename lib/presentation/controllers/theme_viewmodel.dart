import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/facades/tema_facade_usecases_interface.dart';
import '../../domain/models/preferencia_tema.dart';
import '../commands/tema_commands.dart';

/// Controla o tema claro/escuro e sua persistência local (SharedPreferences).
class ThemeViewModel {
  final CarregarTemaCommand _carregarCmd;
  final AlterarTemaCommand _alterarCmd;

  ThemeViewModel(ITemaFacadeUseCases facade)
      : _carregarCmd = CarregarTemaCommand(facade),
        _alterarCmd = AlterarTemaCommand(facade);

  final themeMode = signal<ThemeMode>(_toThemeMode(PreferenciaTema.padrao));
  late final isLightMode = computed(() => themeMode.value == ThemeMode.light);
  /// Falha ao salvar a preferência (o tema continua aplicado nesta sessão).
  final erro = signal<String?>(null);

  // Gravações em sequência: cada uma salva o tema vigente no momento em que roda,
  // então alternâncias rápidas sempre terminam com o último tema escolhido salvo.
  Future<void> _filaGravacao = Future.value();

  /// Recupera a última preferência salva. Chamado antes de exibir a interface.
  Future<void> carregarTema() async {
    final result = await _carregarCmd.executeWith(());
    result.fold(
      onSuccess: (tema) => themeMode.value = _toThemeMode(tema),
      onFailure: (e) => erro.value = e.msg, // mantém o tema padrão
    );
  }

  /// Alterna entre claro e escuro e salva a escolha imediatamente.
  Future<void> alternarTema() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    return _filaGravacao = _filaGravacao.then((_) => _salvarTemaAtual());
  }

  Future<void> _salvarTemaAtual() async {
    final tema = themeMode.peek() == ThemeMode.light
        ? PreferenciaTema.claro
        : PreferenciaTema.escuro;
    final result = await _alterarCmd.executeWith((tema: tema));
    erro.value = result.fold(onSuccess: (_) => null, onFailure: (e) => e.msg);
  }

  static ThemeMode _toThemeMode(PreferenciaTema tema) =>
      tema == PreferenciaTema.claro ? ThemeMode.light : ThemeMode.dark;
}
