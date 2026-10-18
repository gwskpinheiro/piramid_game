import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/preferencia_tema.dart';
import '../services/local_storage_interface.dart';
import 'preference_repository_interface.dart';

final class PreferenceRepositoryImpl implements IPreferenceRepository {
  static const chaveTema = 'tema';

  final ILocalStorageService _localStorage;

  PreferenceRepositoryImpl({required ILocalStorageService localStorage})
      : _localStorage = localStorage;

  @override
  Future<TemaResult> obterTema() async {
    final lido = await _localStorage.lerTexto(chaveTema);
    return lido.fold(
      onSuccess: (valor) => Success(
          PreferenciaTema.values.asNameMap()[valor] ?? PreferenciaTema.padrao),
      onFailure: (f) => r.Error(f),
    );
  }

  @override
  Future<VoidResult> salvarTema(PreferenciaTema tema) =>
      _localStorage.salvarTexto(chaveTema, tema.name);
}
