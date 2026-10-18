import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../controllers/auth_viewmodel.dart';
import '../../controllers/vinculo_viewmodel.dart';
import '../../widgets/auth_header.dart';

/// Etapa obrigatória após o login para contas sem vínculo: o usuário escolhe
/// o próprio perfil entre as pessoas ainda não vinculadas ou cadastra o seu.
/// Ao vincular, o roteador leva automaticamente à Home.
class IdentificacaoView extends StatefulWidget {
  const IdentificacaoView({super.key});

  @override
  State<IdentificacaoView> createState() => _IdentificacaoViewState();
}

class _IdentificacaoViewState extends State<IdentificacaoView> {
  late final VinculoViewModel _vm;
  late final AuthViewModel _authVm;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<VinculoViewModel>();
    _authVm = injector.get<AuthViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_vm.possuiVinculo.value == null && !_vm.verificando.value) _vm.verificarVinculo();
      _vm.carregarPessoasDisponiveis();
    });
  }

  /// Confirma (o vínculo é definitivo) e executa a vinculação.
  Future<void> _confirmarEVincular(String descricao, Future<bool> Function() vincular) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar perfil'),
        content: Text('$descricao\n\nEsse vínculo é definitivo e não poderá ser alterado depois.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmar != true) return;
    final ok = await vincular();
    if (!mounted || ok) return; // sucesso: o roteador leva à Home
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_vm.mensagem.value ?? 'Não foi possível vincular o perfil.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identifique seu perfil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair',
            onPressed: () => _authVm.commands.sair(),
          ),
        ],
      ),
      body: Watch((_) {
        if (_vm.verificando.value || (_vm.possuiVinculo.value == null && _vm.erroVerificacao.value == null)) {
          return const Center(child: CircularProgressIndicator());
        }
        final erro = _vm.erroVerificacao.value;
        if (erro != null) {
          return _Erro(mensagem: erro, onTentarNovamente: _vm.verificarVinculo);
        }
        return DefaultTabController(
          length: 2,
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: _Explicacao(),
            ),
            const TabBar(tabs: [
              Tab(icon: Icon(Icons.person_search_rounded), text: 'Já estou cadastrado'),
              Tab(icon: Icon(Icons.person_add_alt_1_rounded), text: 'Cadastrar meu perfil'),
            ]),
            Expanded(
              child: TabBarView(children: [
                _EscolherPerfil(
                  vm: _vm,
                  onEscolher: (p) => _confirmarEVincular(
                    'Você é ${p.nome}${p.apelido.isNotEmpty ? ' ("${p.apelido}")' : ''}, '
                    '${p.curso.displayName} ${p.turmaAno}?',
                    () => _vm.vincularPessoa(p.id),
                  ),
                ),
                _CadastrarPerfil(
                  salvando: _vm.salvando.value,
                  onCadastrar: (p) => _confirmarEVincular(
                    'Cadastrar e vincular o perfil de ${p.nome} à sua conta?',
                    () => _vm.cadastrarPerfil(p),
                  ),
                ),
              ]),
            ),
          ]),
        );
      }),
    );
  }
}

class _Explicacao extends StatelessWidget {
  const _Explicacao();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      const AuthHeader(subtitulo: 'Quem é você no IFPR – Campus Paranaguá?'),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Para avaliar outras pessoas, vincule sua conta ao seu próprio perfil: '
        'escolha-o na lista ou cadastre-o. Cada perfil pertence a uma única conta, '
        'e você nunca poderá avaliar a si mesmo.',
        textAlign: TextAlign.center,
        style: context.textStyles.bodySmall
            ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
      ),
      const SizedBox(height: AppSpacing.sm),
    ]);
  }
}

class _EscolherPerfil extends StatefulWidget {
  final VinculoViewModel vm;
  final ValueChanged<Pessoa> onEscolher;
  const _EscolherPerfil({required this.vm, required this.onEscolher});

  @override
  State<_EscolherPerfil> createState() => _EscolherPerfilState();
}

class _EscolherPerfilState extends State<_EscolherPerfil> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Watch((_) {
      final vm = widget.vm;
      if (vm.carregandoPessoas.value && vm.pessoasDisponiveis.value.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final erro = vm.erroPessoas.value;
      if (erro != null && vm.pessoasDisponiveis.value.isEmpty) {
        return _Erro(mensagem: erro, onTentarNovamente: vm.carregarPessoasDisponiveis);
      }
      final termo = _busca.trim().toLowerCase();
      final lista = vm.pessoasDisponiveis.value.where((p) =>
          termo.isEmpty ||
          p.nome.toLowerCase().contains(termo) ||
          p.apelido.toLowerCase().contains(termo)).toList();

      return Column(children: [
        Padding(
          padding: AppSpacing.paddingMd,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar pelo nome ou apelido...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _busca = v),
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: Text(
                      'Nenhum perfil disponível encontrado.\n'
                      'Se você ainda não está cadastrado, use a aba "Cadastrar meu perfil".',
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodyMedium
                          ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: vm.carregarPessoasDisponiveis,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final p = lista[i];
                      return Card(
                        child: ListTile(
                          enabled: !vm.salvando.value,
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withValues(alpha: 0.15),
                            child: Text(p.nome[0].toUpperCase(),
                                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(p.nome, style: context.textStyles.titleSmall?.semiBold),
                          subtitle: Text(
                            '${p.apelido.isNotEmpty ? '"${p.apelido}" · ' : ''}'
                            '${p.curso.displayName} · ${p.turmaAno}',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => widget.onEscolher(p),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ]);
    });
  }
}

class _CadastrarPerfil extends StatefulWidget {
  final bool salvando;
  final ValueChanged<Pessoa> onCadastrar;
  const _CadastrarPerfil({required this.salvando, required this.onCadastrar});

  @override
  State<_CadastrarPerfil> createState() => _CadastrarPerfilState();
}

class _CadastrarPerfilState extends State<_CadastrarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _apelidoCtrl = TextEditingController();
  Curso _curso = Curso.tads;
  int _turma = 2024;
  DateTime _nascimento = DateTime(2000, 1, 1);

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _apelidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _nascimento,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: 'Data de Nascimento',
    );
    if (data != null) setState(() => _nascimento = data);
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    final agora = DateTime.now();
    widget.onCadastrar(Pessoa(
      id: '',
      nome: _nomeCtrl.text.trim(),
      apelido: _apelidoCtrl.text.trim(),
      curso: _curso,
      turmaAno: _turma,
      dataNascimento: _nascimento,
      criadoPor: '', // definido no use case com o uid da conta
      createdAt: agora,
      updatedAt: agora,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.paddingMd,
        children: [
          TextFormField(
            controller: _nomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'O nome é obrigatório.' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _apelidoCtrl,
            decoration: const InputDecoration(
              labelText: 'Apelido',
              prefixIcon: Icon(Icons.tag),
              border: OutlineInputBorder(),
            ),
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<Curso>(
            initialValue: _curso,
            decoration: const InputDecoration(
              labelText: 'Curso *',
              prefixIcon: Icon(Icons.school),
              border: OutlineInputBorder(),
            ),
            items: Curso.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                .toList(),
            onChanged: (v) => setState(() => _curso = v!),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            initialValue: _turma,
            decoration: const InputDecoration(
              labelText: 'Turma/Ano *',
              prefixIcon: Icon(Icons.calendar_view_month),
              border: OutlineInputBorder(),
            ),
            items: List.generate(2026 - 1998 + 1, (i) => 2026 - i)
                .map((ano) => DropdownMenuItem(value: ano, child: Text('$ano')))
                .toList(),
            onChanged: (v) => setState(() => _turma = v!),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _escolherData,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento *',
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.edit_calendar_outlined),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_nascimento)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: widget.salvando ? null : _enviar,
              icon: widget.salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.how_to_reg_rounded),
              label: const Text('Cadastrar e vincular meu perfil'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onTentarNovamente;
  const _Erro({required this.mensagem, required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: scheme.error.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.md),
          Text(mensagem, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onTentarNovamente,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ]),
      ),
    );
  }
}
