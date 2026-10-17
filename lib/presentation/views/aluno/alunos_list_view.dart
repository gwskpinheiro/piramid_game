import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../../presentation/controllers/auth_viewmodel.dart';
import '../../../presentation/controllers/pessoa_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class AlunosListView extends StatefulWidget {
  const AlunosListView({super.key});

  @override
  State<AlunosListView> createState() => _AlunosListViewState();
}

class _AlunosListViewState extends State<AlunosListView> {
  late final PessoaViewModel _vm;
  late final AuthViewModel _authVm;
  final _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _vm = injector.get<PessoaViewModel>();
    _authVm = injector.get<AuthViewModel>();
    _buscaCtrl.addListener(() {
      setState(() => _termoBusca = _buscaCtrl.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.commands.carregarPessoas();
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  List<Pessoa> _filtrar(List<Pessoa> alunos) {
    if (_termoBusca.isEmpty) return alunos;
    return alunos.where((a) {
      return a.nome.toLowerCase().contains(_termoBusca) ||
          a.apelido.toLowerCase().contains(_termoBusca) ||
          a.curso.displayName.toLowerCase().contains(_termoBusca) ||
          a.turmaAno.toString().contains(_termoBusca);
    }).toList();
  }

  Future<void> _confirmarExclusao(BuildContext context, Pessoa aluno) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Aluno'),
        content: Text(
            'Deseja remover "${aluno.nome}"?\nEssa ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await _vm.commands.deletarPessoa(aluno.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok
              ? '"${aluno.nome}" removido.'
              : (_vm.pessoaState.mensagem.value ?? 'Não foi possível remover.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
        actions: [
          Watch((_) {
            final total = _vm.pessoaState.totalPessoas.value;
            if (total == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$total aluno${total == 1 ? '' : 's'}',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(AppRouteNames.alunoForm),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Novo Aluno'),
      ),
      body: Watch((_) {
        if (_vm.pessoaState.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final todos = _vm.pessoaState.pessoas.value;
        final erro = _vm.pessoaState.mensagem.value;

        if (todos.isEmpty && erro != null) {
          return EmptyState(
            icon: Icons.cloud_off_rounded,
            message: erro,
            actionLabel: 'Tentar novamente',
            onAction: _vm.commands.carregarPessoas,
          );
        }

        if (todos.isEmpty) {
          return EmptyState(
            icon: Icons.school_rounded,
            message: 'Nenhum aluno cadastrado.\nCadastre o primeiro!',
            actionLabel: 'Cadastrar Aluno',
            onAction: () => context.goNamed(AppRouteNames.alunoForm),
          );
        }

        final filtrados = _filtrar(todos);

        return Column(
          children: [
            // ── Barra de busca ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: TextField(
                controller: _buscaCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, apelido, curso...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _termoBusca.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _buscaCtrl.clear();
                            setState(() => _termoBusca = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                ),
              ),
            ),

            // ── Resultado da busca ────────────────────────────────────────
            if (_termoBusca.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14,
                        color: scheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      filtrados.isEmpty
                          ? 'Nenhum aluno encontrado para "$_termoBusca"'
                          : '${filtrados.length} resultado${filtrados.length == 1 ? '' : 's'} para "$_termoBusca"',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Lista ─────────────────────────────────────────────────────
            Expanded(
              child: filtrados.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      message:
                          'Nenhum aluno encontrado\npara "$_termoBusca".',
                    )
                  : RefreshIndicator(
                      onRefresh: _vm.commands.carregarPessoas,
                      child: ListView.separated(
                        padding: AppSpacing.paddingMd,
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final aluno = filtrados[index];
                          return _AlunoCard(
                            podeGerenciar: _authVm.authState.usuario.value?.uid ==
                                aluno.criadoPor,
                            aluno: aluno,
                            termoBusca: _termoBusca,
                            onTap: () => context.goNamed(
                              AppRouteNames.alunoDetalhe,
                              pathParameters: {'id': aluno.id},
                            ),
                            onEdit: () => context.goNamed(
                              'aluno_form_edit',
                              pathParameters: {'id': aluno.id},
                            ),
                            onDelete: () =>
                                _confirmarExclusao(context, aluno),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _AlunoCard extends StatelessWidget {
  final Pessoa aluno;
  final String termoBusca;
  /// Editar/remover só aparecem para quem cadastrou a pessoa.
  final bool podeGerenciar;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlunoCard({
    required this.aluno,
    required this.termoBusca,
    required this.podeGerenciar,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primary.withOpacity(0.15),
                child: Text(
                  aluno.nome[0].toUpperCase(),
                  style: context.textStyles.titleLarge?.copyWith(
                    color: scheme.primary, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome com destaque no trecho buscado
                    _HighlightText(
                      text: aluno.nome,
                      termo: termoBusca,
                      style: context.textStyles.titleSmall?.semiBold,
                      highlightColor: scheme.primary,
                    ),
                    if (aluno.apelido.isNotEmpty)
                      _HighlightText(
                        text: '"${aluno.apelido}"',
                        termo: termoBusca,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                        highlightColor: scheme.secondary,
                      ),
                    Row(
                      children: [
                        Icon(Icons.school,
                            size: 12,
                            color: scheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          '${aluno.curso.displayName} · ${aluno.turmaAno}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!podeGerenciar)
                Icon(Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.4)),
              if (podeGerenciar)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remover', style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destaca o trecho encontrado na busca com cor diferente
class _HighlightText extends StatelessWidget {
  final String text;
  final String termo;
  final TextStyle? style;
  final Color highlightColor;

  const _HighlightText({
    required this.text,
    required this.termo,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (termo.isEmpty) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final idx = lower.indexOf(termo.toLowerCase());

    if (idx == -1) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + termo.length),
            style: style?.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.bold,
              backgroundColor: highlightColor.withOpacity(0.15),
            ),
          ),
          if (idx + termo.length < text.length)
            TextSpan(text: text.substring(idx + termo.length)),
        ],
      ),
    );
  }
}
