import 'package:shared_preferences/shared_preferences.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import 'local_storage_interface.dart';

/// Implementação de [ILocalStorageService] com SharedPreferences
/// (Android: SharedPreferences nativo; Web: localStorage do navegador).
final class LocalStorageService implements ILocalStorageService {
  Future<SharedPreferences>? _prefs;
  Future<SharedPreferences> get _instancia => _prefs ??= SharedPreferences.getInstance();

  @override
  Future<TextoOpcionalResult> lerTexto(String chave) async {
    try {
      final prefs = await _instancia;
      return Success(prefs.getString(chave));
    } catch (_) {
      return r.Error(ApiLocalFailure('Não foi possível ler as preferências locais.'));
    }
  }

  @override
  Future<VoidResult> salvarTexto(String chave, String valor) async {
    try {
      final prefs = await _instancia;
      final ok = await prefs.setString(chave, valor);
      if (!ok) return r.Error(ApiLocalFailure('Não foi possível salvar a preferência.'));
      return const Success(null);
    } catch (_) {
      return r.Error(ApiLocalFailure('Não foi possível salvar a preferência.'));
    }
  }
}
