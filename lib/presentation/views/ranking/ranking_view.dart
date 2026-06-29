import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/aluno_entity.dart';
import '../../../presentation/controllers/aluno_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class RankingView extends StatefulWidget {
  const RankingView({super.key});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  late final AlunoViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AlunoViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.commands.carregarAlunos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Ranking')),
      drawer: const AppDrawer(),
      body: Watch((_) {
        if (_vm.alunoState.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ranking = _vm.alunoState.ranking.value;

        if (ranking.isEmpty) {
          return EmptyState(
            icon: Icons.leaderboard_rounded,
            message:
                'Nenhum aluno no ranking ainda.\nCadastre alunos para começar!',
            actionLabel: 'Cadastrar Aluno',
            onAction: () => context.goNamed(AppRouteNames.alunoForm),
          );
        }

        return RefreshIndicator(
          onRefresh: _vm.commands.carregarAlunos,
          child: ListView(
            padding: AppSpacing.paddingMd,
            children: [
              const SizedBox(height: AppSpacing.sm),
              _PodioSection(ranking: ranking),
              const SizedBox(height: AppSpacing.xl),
              if (ranking.length > 3) ...[
                Text('Demais posições',
                    style: context.textStyles.titleMedium?.semiBold),
                const SizedBox(height: AppSpacing.md),
                ...ranking.skip(3).toList().asMap().entries.map((e) {
                  final pos = e.key + 4;
                  final aluno = e.value;
                  return _RankingItem(
                    posicao: pos,
                    aluno: aluno,
                    onTap: () => context.goNamed(
                      AppRouteNames.alunoDetalhe,
                      pathParameters: {'id': aluno.id},
                    ),
                  );
                }),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      }),
    );
  }
}

// ── Pódio ──────────────────────────────────────────────────────────────────
class _PodioSection extends StatelessWidget {
  final List<Aluno> ranking;
  const _PodioSection({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final top1 = ranking[0];
    final top2 = ranking.length > 1 ? ranking[1] : null;
    final top3 = ranking.length > 2 ? ranking[2] : null;

    // Cada coluna tem peso de "altura relativa" via flex no IntrinsicHeight
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🥇 Pódio', style: context.textStyles.titleLarge?.semiBold),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2º lugar
            Expanded(
              child: top2 != null
                  ? _PodioCard(
                      aluno: top2,
                      emoji: '🥈',
                      medalColor: const Color(0xFFC0C0C0),
                      extraTopPadding: 0,
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 1º lugar — espaço extra no topo para parecer mais alto
            Expanded(
              child: _PodioCard(
                aluno: top1,
                emoji: '🥇',
                medalColor: const Color(0xFFFFD700),
                extraTopPadding: 40,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 3º lugar
            Expanded(
              child: top3 != null
                  ? _PodioCard(
                      aluno: top3,
                      emoji: '🥉',
                      medalColor: const Color(0xFFCD7F32),
                      extraTopPadding: 0,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ],
    );
  }
}

class _PodioCard extends StatelessWidget {
  final Aluno aluno;
  final String emoji;
  final Color medalColor;
  // Padding extra no topo faz o 1º lugar parecer maior sem forçar altura
  final double extraTopPadding;

  const _PodioCard({
    required this.aluno,
    required this.emoji,
    required this.medalColor,
    this.extraTopPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(
        AppRouteNames.alunoDetalhe,
        pathParameters: {'id': aluno.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: medalColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: medalColor.withOpacity(0.5), width: 2),
        ),
        // Padding top maior no 1º lugar = card visualmente mais alto
        padding: EdgeInsets.fromLTRB(6, 10 + extraTopPadding, 6, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ← não força altura, cresce com conteúdo
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 16,
              backgroundColor: medalColor.withOpacity(0.3),
              child: Text(
                aluno.nome[0].toUpperCase(),
                style: TextStyle(
                  color: medalColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              aluno.nome.split(' ').first,
              style: context.textStyles.bodySmall?.semiBold,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            if (aluno.apelido.isNotEmpty)
              Text(
                '"${aluno.apelido}"',
                style: context.textStyles.bodySmall?.copyWith(
                  color: medalColor,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: medalColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${aluno.nivelLenda} pts',
                style: TextStyle(
                  color: medalColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item de ranking (4+) ──────────────────────────────────────────────────
class _RankingItem extends StatelessWidget {
  final int posicao;
  final Aluno aluno;
  final VoidCallback onTap;

  const _RankingItem({
    required this.posicao,
    required this.aluno,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '$posicao°',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.45),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  aluno.nome[0].toUpperCase(),
                  style: context.textStyles.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(aluno.nome,
                        style: context.textStyles.titleSmall?.semiBold,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${aluno.curso.displayName} · ${aluno.turmaAno}'
                      '${aluno.apelido.isNotEmpty ? ' · "${aluno.apelido}"' : ''}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.55),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${aluno.nivelLenda} pts',
                  style: context.textStyles.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
