import '../../core/typedefs/types_defs.dart';
import '../../domain/models/preferencia_tema.dart';

abstract interface class IPreferenceRepository {
  /// Tema salvo, ou [PreferenciaTema.padrao] se não houver preferência válida.
  Future<TemaResult> obterTema();
  Future<VoidResult> salvarTema(PreferenciaTema tema);
}
