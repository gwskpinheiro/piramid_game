import 'package:signals_flutter/signals_flutter.dart';

import 'result.dart';

// Interface base para comandos
abstract interface class ICommand<Success, Error> {
  Future<Result<Success, Error>> execute();
}

// Comando abstrato com estado reativo
abstract base class Command<Success, Error>
    implements ICommand<Success, Error> {
  final _running = signal(false);
  final _result = signal<Result<Success, Error>?>(null);

  //final _error = signal<TError?>(null);

  // Getters para os sinais reativos
  ReadonlySignal<bool> get isExecuting => _running.readonly();
  ReadonlySignal<Result<Success, Error>?> get result => _result.readonly();
  //ReadonlySignal<TError?> get error => _error.readonly();

  // Computed signals
  late final hasResult = computed(() => _result.value != null);
  late final hasError = computed(() => _result.value?.isFailure ?? false);
  late final isSuccess = computed(() => _result.value?.isSuccess ?? false);
  // late final data = computed(() => _result.value?.successValueOrNull);

  // Execução em andamento (reaproveitada se call() for chamado de novo)
  Future<Result<Success, Error>>? _emAndamento;
  // Identifica a execução atual; reset() troca o token e invalida as anteriores.
  Object _token = Object();

  // Método para executar o comando com tratamento
  Future<Result<Success, Error>> call() {
    final existente = _emAndamento;
    if (existente != null) return existente;
    late final Future<Result<Success, Error>> futuro;
    futuro = _executar(_token).whenComplete(() {
      if (identical(_emAndamento, futuro)) _emAndamento = null;
    });
    return _emAndamento = futuro;
  }

  Future<Result<Success, Error>> _executar(Object token) async {
    _running.value = true; // indica que está rodando
    _result.value = null; // limpa resultado anterior
    try {
      final result = await execute(); // executa a ação
      if (identical(token, _token)) _result.value = result;
      return result;
    } finally {
      // indica que terminou (mesmo com exceção), se não foi descartada
      if (identical(token, _token)) _running.value = false;
    }
  }

  void clear() {
    _result.value = null;
  }

  /// Descarta a execução em andamento: a próxima chamada a call() inicia uma
  /// nova execução em vez de reaproveitar a anterior (ex.: troca de usuário).
  void reset() {
    _token = Object();
    _emAndamento = null;
    _running.value = false;
    clear();
  }
}

// Comando parametrizado
abstract base class ParameterizedCommand<Success, Error, P>
    extends Command<Success, Error> {
  P? _parameter;

  set parameter(P? value) => _parameter = value;
  P? get parameter => _parameter;

  Future<Result<Success, Error>> executeWith(P parameter) {
    _parameter = parameter;
    return call();
  }

  @override
  Future<Result<Success, Error>> execute();
}

// Comando composto que executa múltiplos comandos e acumula resultados
final class CompositeCommand<TOk, TError> extends Command<List<TOk>, TError> {
  final List<Command<TOk, TError>> _commands;

  CompositeCommand(this._commands);

  @override
  Future<Result<List<TOk>, TError>> execute() async {
    final results = <TOk>[];

    for (final command in _commands) {
      final result =
          await command.call(); // usa o call() para registrar estados

      if (result.isFailure) {
        return Error(result.failureValueOrNull as TError);
      }

      final value = result.successValueOrNull;
      if (value != null) {
        results.add(value);
      }
    }

    return Success(results);
  }
}
