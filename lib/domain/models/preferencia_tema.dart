/// Preferência de tema do aplicativo, salva localmente no aparelho.
enum PreferenciaTema {
  claro,
  escuro;

  /// Tema usado quando não há preferência salva (ou ela é inválida).
  static const padrao = PreferenciaTema.escuro;
}
