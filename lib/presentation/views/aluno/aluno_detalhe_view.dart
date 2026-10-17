import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/avaliacao_entity.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../../presentation/controllers/auth_viewmodel.dart';
import '../../../presentation/controllers/avaliacao_viewmodel.dart';
import '../../../presentation/controllers/pessoa_viewmodel.dart';
import '../../widgets/aviso_avaliacao.dart';

class AlunoDetalheView extends StatefulWidget {
  final String alunoId;
  const AlunoDetalheView({super.key, required this.alunoId});

  @override
  State<AlunoDetalheView> createState() => _AlunoDetalheViewState();
}

class _AlunoDetalheViewState extends State<AlunoDetalheView> {
  late final PessoaViewModel _vm;
  late final AuthViewModel _authVm;
  late final AvaliacaoViewModel _avaliacaoVm;
  Pessoa? _aluno;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<PessoaViewModel>();
    _authVm = injector.get<AuthViewModel>();
    _avaliacaoVm = injector.get<AvaliacaoViewModel>();
    // Após o primeiro frame, pelo mesmo motivo da tela de avaliação: os
    // signals de avaliação são compartilhados e observados por outras telas.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _avaliacaoVm.commands.carregar(widget.alunoId);
    });
    _buscar();
  }

  Future<void> _buscar() async {
    // Tenta primeiro na lista em memória (mais rápido)
    final emMemoria = _vm.pessoaState.pessoas.value;
    if (emMemoria.isNotEmpty) {
      try {
        final encontrado = emMemoria.firstWhere((a) => a.id == widget.alunoId);
        setState(() { _aluno = encontrado; _loading = false; });
        return;
      } catch (_) {}
    }
    // Se não encontrou em memória, busca no Firestore pelo identificador
    final aluno = await _vm.commands.buscarPessoaPorId(widget.alunoId);
    if (!mounted) return;
    setState(() { _aluno = aluno; _loading = false; });
  }

  Future<void> _confirmarExclusao(Pessoa aluno) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Aluno'),
        content: Text('Deseja remover "${aluno.nome}"?\nEssa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await _vm.commands.deletarPessoa(aluno.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '"${aluno.nome}" removido.'
          : (_vm.pessoaState.mensagem.value ?? 'Não foi possível remover.')),
    ));
    if (ok) context.goNamed(AppRouteNames.alunos);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_aluno == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.goNamed(AppRouteNames.alunos),
          ),
        ),
        body: Center(child: Text(_vm.pessoaState.mensagem.value ?? 'Aluno não encontrado.')),
      );
    }

    final aluno = _aluno!;
    // Edição/exclusão só para quem cadastrou (também garantido pelas regras).
    final ehCriador = _authVm.authState.usuario.value?.uid == aluno.criadoPor;

    return Scaffold(
      appBar: AppBar(
        title: Text(aluno.nome),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(AppRouteNames.alunos),
        ),
        actions: [
          if (ehCriador) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Editar',
              onPressed: () => context.goNamed(
                'aluno_form_edit',
                pathParameters: {'id': aluno.id},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Remover',
              onPressed: () => _confirmarExclusao(aluno),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(aluno: aluno),
            const SizedBox(height: AppSpacing.lg),
            _MinhaAvaliacaoCard(vm: _avaliacaoVm, pessoaId: aluno.id),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cadastrado em: ${DateFormat('dd/MM/yyyy HH:mm').format(aluno.createdAt)}'
              '${ehCriador ? ' · por você' : ''}',
              style: context.textStyles.bodySmall
                  ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Pessoa aluno;
  const _ProfileHeader({required this.aluno});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              aluno.nome[0].toUpperCase(),
              style: context.textStyles.headlineMedium?.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(aluno.nome,
              style: context.textStyles.headlineSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center),
          if (aluno.apelido.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('"${aluno.apelido}"',
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontStyle: FontStyle.italic,
                )),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _Chip(label: aluno.curso.displayName),
              _Chip(label: '${aluno.turmaAno}'),
              _Chip(
                label: DateFormat('dd/MM/yyyy').format(aluno.dataNascimento),
                icon: Icons.cake_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _Chip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

/// Situação da avaliação do usuário autenticado sobre esta pessoa:
/// aviso (sem vínculo / autoavaliação), botão Avaliar ou Editar avaliação.
class _MinhaAvaliacaoCard extends StatelessWidget {
  final AvaliacaoViewModel vm;
  final String pessoaId;
  const _MinhaAvaliacaoCard({required this.vm, required this.pessoaId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Watch((_) {
      final st = vm.avaliacaoState;
      if (st.isLoading.value || st.pessoaId.value != pessoaId) {
        return const Padding(
          padding: AppSpacing.paddingMd,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final erro = st.erroCarregamento.value;
      final permissao = st.permissao.value;
      if (erro != null || permissao == null) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(erro ?? 'Não foi possível verificar se você pode avaliar esta pessoa.',
              style: context.textStyles.bodySmall?.copyWith(color: scheme.error)),
          TextButton.icon(
            onPressed: () => vm.commands.carregar(pessoaId),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ]);
      }
      if (permissao != PermissaoAvaliacao.permitida) {
        return AvisoAvaliacao(permissao: permissao);
      }

      final avaliacao = st.avaliacaoAtual.value;
      return Container(
        width: double.infinity,
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('⭐ Minha Avaliação', style: context.textStyles.titleMedium?.semiBold),
              Text(
                avaliacao == null
                    ? 'Você ainda não avaliou esta pessoa.'
                    : 'Avaliada em ${DateFormat('dd/MM/yyyy HH:mm').format(avaliacao.dataAvaliacao)}',
                style: context.textStyles.bodySmall
                    ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
              ),
            ]),
            if (avaliacao != null)
              Text('${avaliacao.nivelLenda} pts',
                  style: context.textStyles.headlineSmall
                      ?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.avaliar,
                  pathParameters: {'id': pessoaId}),
              icon: Icon(avaliacao == null ? Icons.star_rounded : Icons.edit_rounded),
              label: Text(avaliacao == null ? 'Avaliar' : 'Editar minha avaliação'),
            ),
          ),
        ]),
      );
    });
  }
}
