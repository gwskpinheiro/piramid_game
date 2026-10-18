import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/data/repositories/preference_repository_impl.dart';
import 'package:piramid_game/data/services/local_storage_interface.dart';
import 'package:piramid_game/data/services/local_storage_service.dart';
import 'package:piramid_game/domain/facades/tema_facade_usecases_impl.dart';
import 'package:piramid_game/domain/usecases/tema_usecases_impl.dart';
import 'package:piramid_game/presentation/controllers/theme_viewmodel.dart';

/// Monta a cadeia completa, como o app faz ao iniciar.
ThemeViewModel _iniciarApp([ILocalStorageService? storage]) {
  final repo = PreferenceRepositoryImpl(localStorage: storage ?? LocalStorageService());
  final facade = TemaFacadeUseCasesImpl(
    obter: ObterTemaUseCaseImpl(repository: repo),
    alterar: AlterarTemaUseCaseImpl(repository: repo),
  );
  return ThemeViewModel(facade);
}

Future<String?> _temaSalvo() async =>
    (await SharedPreferences.getInstance()).getString(PreferenceRepositoryImpl.chaveTema);

/// Armazenamento que sempre falha (ex.: navegador bloqueando o localStorage).
class _StorageComFalha implements ILocalStorageService {
  @override
  Future<TextoOpcionalResult> lerTexto(String chave) async =>
      Error(ApiLocalFailure('Não foi possível ler as preferências locais.'));
  @override
  Future<VoidResult> salvarTexto(String chave, String valor) async =>
      Error(ApiLocalFailure('Não foi possível salvar a preferência.'));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sem preferência salva, inicia no tema padrão (escuro)', () async {
    final vm = _iniciarApp();
    await vm.carregarTema();
    expect(vm.themeMode.value, ThemeMode.dark);
    expect(vm.isLightMode.value, isFalse);
    expect(vm.erro.value, isNull);
  });

  test('alternar salva imediatamente no SharedPreferences', () async {
    final vm = _iniciarApp();
    await vm.carregarTema();

    await vm.alternarTema();
    expect(vm.themeMode.value, ThemeMode.light);
    expect(await _temaSalvo(), 'claro');

    await vm.alternarTema();
    expect(vm.themeMode.value, ThemeMode.dark);
    expect(await _temaSalvo(), 'escuro');
  });

  test('a preferência sobrevive ao reinício do app', () async {
    final primeiraExecucao = _iniciarApp();
    await primeiraExecucao.carregarTema();
    await primeiraExecucao.alternarTema(); // escolhe claro

    final segundaExecucao = _iniciarApp();
    expect(segundaExecucao.themeMode.value, ThemeMode.dark); // antes de carregar
    await segundaExecucao.carregarTema();
    expect(segundaExecucao.themeMode.value, ThemeMode.light);
  });

  test('recupera tema claro salvo anteriormente', () async {
    SharedPreferences.setMockInitialValues({'tema': 'claro'});
    final vm = _iniciarApp();
    await vm.carregarTema();
    expect(vm.themeMode.value, ThemeMode.light);
  });

  test('alternâncias rápidas terminam salvando o último tema escolhido', () async {
    final vm = _iniciarApp();
    await vm.carregarTema();

    vm.alternarTema(); // claro
    vm.alternarTema(); // escuro
    final ultima = vm.alternarTema(); // claro
    expect(vm.themeMode.value, ThemeMode.light); // UI muda na hora
    await ultima;

    expect(await _temaSalvo(), 'claro');
    final reiniciado = _iniciarApp();
    await reiniciado.carregarTema();
    expect(reiniciado.themeMode.value, ThemeMode.light);
  });

  test('valor inválido salvo volta ao tema padrão', () async {
    SharedPreferences.setMockInitialValues({'tema': 'roxo'});
    final vm = _iniciarApp();
    await vm.carregarTema();
    expect(vm.themeMode.value, ThemeMode.dark);
  });

  test('somente a preferência de tema é gravada (nada de credenciais)', () async {
    final vm = _iniciarApp();
    await vm.carregarTema();
    await vm.alternarTema();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'tema'});
  });

  test('falha ao ler mantém o tema padrão sem travar a inicialização', () async {
    final vm = _iniciarApp(_StorageComFalha());
    await vm.carregarTema();
    expect(vm.themeMode.value, ThemeMode.dark);
    expect(vm.erro.value, contains('ler as preferências'));
  });

  test('falha ao salvar mantém o tema escolhido na sessão e informa o erro', () async {
    final vm = _iniciarApp(_StorageComFalha());
    await vm.alternarTema();
    expect(vm.themeMode.value, ThemeMode.light);
    expect(vm.erro.value, contains('salvar a preferência'));
  });
}
