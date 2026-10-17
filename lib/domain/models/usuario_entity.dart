import 'package:equatable/equatable.dart';

/// Usuário autenticado no app (independente do provedor de autenticação).
class Usuario extends Equatable {
  final String uid;
  final String? email;
  final String? nome;
  final String? fotoUrl;
  /// Provedor usado no login: 'password' (e-mail/senha) ou 'google.com'.
  final String provider;

  const Usuario({
    required this.uid,
    this.email,
    this.nome,
    this.fotoUrl,
    this.provider = 'password',
  });

  /// Nome para exibição: nome do perfil, ou e-mail, ou um padrão.
  String get nomeExibicao {
    if (nome != null && nome!.trim().isNotEmpty) return nome!;
    if (email != null && email!.isNotEmpty) return email!;
    return 'Usuário';
  }

  @override
  List<Object?> get props => [uid, email, nome, fotoUrl, provider];
}
