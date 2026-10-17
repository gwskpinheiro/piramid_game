sealed class Failure implements Exception {
  final String msg;
  Failure(this.msg);

  @override
  String toString() => '$runtimeType: $msg';
}

class DefaultFailure extends Failure {
  DefaultFailure([String? msg]) : super(msg ?? 'Ocorreu um erro inesperado.');
}

class ApiLocalFailure extends Failure {
  ApiLocalFailure([String? msg])
      : super(msg ?? 'Erro ao acessar armazenamento local.');
}

class EmptyResultFailure extends Failure {
  EmptyResultFailure([String? msg]) : super(msg ?? 'Nenhum resultado encontrado.');
}

class InputFailure extends Failure {
  InputFailure([String? msg]) : super(msg ?? 'Dados de entrada inválidos.');
}

class NotFoundFailure extends Failure {
  NotFoundFailure([String? msg]) : super(msg ?? 'Item não encontrado.');
}

class RemoteFailure extends Failure {
  RemoteFailure([String? msg])
      : super(msg ?? 'Erro ao acessar o servidor. Tente novamente.');
}

class AuthFailure extends Failure {
  AuthFailure([String? msg])
      : super(msg ?? 'Não foi possível concluir a autenticação.');
}
