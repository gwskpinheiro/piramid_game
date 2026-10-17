import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';
import 'auth_service_interface.dart';

/// Autenticação via Firebase Authentication.
///
/// A sessão é persistida pelo próprio Firebase (Android: armazenamento nativo;
/// Web: IndexedDB). Nenhuma senha é armazenada localmente pelo app.
final class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Inicialização única do GoogleSignIn (exigida pela API 7.x).
  /// O `serverClientId` é lido do google-services.json no Android.
  Future<void>? _googleInit;
  Future<void> _garantirGoogleInicializado() =>
      _googleInit ??= GoogleSignIn.instance.initialize();

  @override
  Stream<Usuario?> observarUsuario() =>
      _auth.authStateChanges().map((u) => u == null ? null : _toUsuario(u));

  @override
  Usuario? get usuarioAtual {
    final u = _auth.currentUser;
    return u == null ? null : _toUsuario(u);
  }

  @override
  Future<UsuarioResult> entrarComEmail(String email, String senha) =>
      _executar(() => _auth.signInWithEmailAndPassword(email: email, password: senha));

  @override
  Future<UsuarioResult> cadastrarComEmail(String email, String senha) =>
      _executar(() => _auth.createUserWithEmailAndPassword(email: email, password: senha));

  @override
  Future<UsuarioResult> entrarComGoogle() => _executar(() async {
        if (kIsWeb) {
          // No Web, o google_sign_in 7.x não suporta authenticate();
          // o fluxo recomendado com Firebase é o popup do próprio Firebase Auth.
          return _auth.signInWithPopup(GoogleAuthProvider());
        }

        await _garantirGoogleInicializado();
        final conta = await GoogleSignIn.instance.authenticate();
        final idToken = conta.authentication.idToken;
        if (idToken == null) {
          throw FirebaseAuthException(code: 'missing-id-token');
        }
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        return _auth.signInWithCredential(credential);
      });

  @override
  Future<VoidResult> sair() async {
    try {
      if (!kIsWeb && _googleInit != null) {
        // Limpa a conta Google escolhida para permitir trocar de conta.
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
      return const Success(null);
    } catch (_) {
      return r.Error(AuthFailure('Não foi possível sair da conta. Tente novamente.'));
    }
  }

  Future<UsuarioResult> _executar(Future<UserCredential> Function() acao) async {
    try {
      final credencial = await acao();
      final user = credencial.user;
      if (user == null) return r.Error(AuthFailure());
      return Success(_toUsuario(user));
    } on FirebaseAuthException catch (e) {
      return r.Error(AuthFailure(_mensagemFirebase(e.code)));
    } on GoogleSignInException catch (e) {
      return r.Error(AuthFailure(_mensagemGoogle(e.code)));
    } catch (_) {
      return r.Error(AuthFailure());
    }
  }

  Usuario _toUsuario(User u) => Usuario(
        uid: u.uid,
        email: u.email,
        nome: u.displayName,
        fotoUrl: u.photoURL,
        provider: u.providerData.isNotEmpty
            ? u.providerData.first.providerId
            : 'password',
      );

  String _mensagemFirebase(String code) => switch (code) {
        'invalid-email' => 'O e-mail informado é inválido.',
        'user-disabled' => 'Esta conta foi desativada.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Já existe uma conta com este e-mail.',
        'weak-password' => 'A senha é muito fraca. Use pelo menos 6 caracteres.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde alguns instantes e tente novamente.',
        'network-request-failed' => 'Sem conexão com a internet. Verifique sua rede.',
        'operation-not-allowed' => 'Este método de login não está habilitado.',
        'account-exists-with-different-credential' =>
          'Este e-mail já está vinculado a outro método de login.',
        'popup-closed-by-user' || 'cancelled-popup-request' =>
          'Login com Google cancelado.',
        'popup-blocked' =>
          'O navegador bloqueou o popup de login. Permita popups e tente novamente.',
        'unauthorized-domain' => 'Este domínio não está autorizado no Firebase.',
        'missing-id-token' => 'Não foi possível obter o token do Google.',
        _ => 'Não foi possível concluir a autenticação. Tente novamente.',
      };

  String _mensagemGoogle(GoogleSignInExceptionCode code) => switch (code) {
        GoogleSignInExceptionCode.canceled => 'Login com Google cancelado.',
        GoogleSignInExceptionCode.interrupted =>
          'O login com Google foi interrompido. Tente novamente.',
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          'Login com Google não configurado corretamente (verifique o SHA-1 no Firebase).',
        GoogleSignInExceptionCode.uiUnavailable =>
          'Não foi possível abrir a tela de login do Google.',
        _ => 'Não foi possível entrar com o Google. Tente novamente.',
      };
}
