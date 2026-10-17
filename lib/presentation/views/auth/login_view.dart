import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_viewmodel.dart';
import '../../widgets/auth_header.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaVisivel = false;

  late final AuthViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AuthViewModel>();
    _vm.authState.limparMensagem();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  // Em caso de sucesso, o redirect do go_router leva automaticamente à Home.
  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _vm.commands.entrarComEmail(_emailCtrl.text, _senhaCtrl.text);
    if (!ok) _mostrarErro();
  }

  Future<void> _entrarComGoogle() async {
    final ok = await _vm.commands.entrarComGoogle();
    if (!ok) _mostrarErro();
  }

  void _mostrarErro() {
    final msg = _vm.authState.mensagem.value;
    if (!mounted || msg == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Watch((_) {
                final loading = _vm.authState.isLoading.value;
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(subtitulo: 'Entre para acessar o ranking'),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: !loading,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Informe o e-mail.' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _senhaCtrl,
                        enabled: !loading,
                        obscureText: !_senhaVisivel,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _entrar(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha.' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: loading ? null : _entrar,
                          icon: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.login_rounded),
                          label: const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Text('ou', style: context.textStyles.bodySmall),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: loading ? null : _entrarComGoogle,
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                          label: const Text('Entrar com Google'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextButton(
                        onPressed: loading ? null : () => context.goNamed(AppRouteNames.cadastro),
                        child: const Text('Não tem conta? Cadastre-se'),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
