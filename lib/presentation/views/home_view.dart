import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/controllers/theme_viewmodel.dart';
import '../../presentation/controllers/ranking_viewmodel.dart';
import '../../presentation/controllers/pessoa_viewmodel.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pontuacao_format.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final RankingViewModel _rankingVm;
  late final PessoaViewModel _pessoaVm;
  late final ThemeViewModel _themeCtrl;

  @override
  void initState() {
    super.initState();
    _rankingVm = injector.get<RankingViewModel>();
    _pessoaVm = injector.get<PessoaViewModel>();
    _themeCtrl = injector.get<ThemeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rankingVm.commands.carregarRankingGlobal();
      _pessoaVm.commands.carregarPessoas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PiramidGame'),
        actions: [
          Watch((_) {
            final isLight = _themeCtrl.isLightMode.value;
            return IconButton(
              icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
              tooltip: 'Alternar tema',
              onPressed: _themeCtrl.alternarTema,
            );
          }),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de boas-vindas
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PiramidGame',
                              style: context.textStyles.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'IFPR – Campus Paranaguá',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Watch((_) {
                    final total = _pessoaVm.pessoaState.totalPessoas.value;
                    return Text(
                      total == 0
                          ? 'Nenhum aluno cadastrado ainda.'
                          : '$total aluno${total == 1 ? '' : 's'} cadastrado${total == 1 ? '' : 's'}!',
                      style: context.textStyles.titleSmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text('Menu Principal', style: context.textStyles.titleLarge?.semiBold),
            const SizedBox(height: AppSpacing.md),

            // Grid de 2x2 com altura fixa
            Row(
              children: [
                Expanded(
                  child: _MenuCard(
                    icon: Icons.people_alt_rounded,
                    label: 'Alunos',
                    subtitle: 'Cadastrar e gerenciar',
                    color: scheme.primary,
                    onTap: () => context.goNamed(AppRouteNames.alunos),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MenuCard(
                    icon: Icons.leaderboard_rounded,
                    label: 'Ranking',
                    subtitle: 'Ver classificação',
                    color: const Color(0xFFFF6B35),
                    onTap: () => context.goNamed(AppRouteNames.ranking),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MenuCard(
                    icon: Icons.person_add_rounded,
                    label: 'Novo Aluno',
                    subtitle: 'Adicionar ao ranking',
                    color: const Color(0xFF00B4D8),
                    onTap: () => context.goNamed(AppRouteNames.alunoForm),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MenuCard(
                    icon: Icons.info_outline_rounded,
                    label: 'Sobre',
                    subtitle: 'Sobre o app',
                    color: const Color(0xFF9C27B0),
                    onTap: () => context.goNamed(AppRouteNames.sobre),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Top 3 preview
            Watch((_) {
              final ranking = _rankingVm.rankingState.top3Global.value;
              if (ranking.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏆 Top 3 do Ranking Global',
                      style: context.textStyles.titleLarge?.semiBold),
                  const SizedBox(height: AppSpacing.md),
                  ...ranking.map((item) {
                    final aluno = item.pessoa;
                    // Medalha pela posição: empates compartilham a medalha.
                    final medalha = switch (item.posicao) { 1 => '🥇', 2 => '🥈', _ => '🥉' };
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Text(medalha, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(aluno.nome,
                                    style:
                                        context.textStyles.titleSmall?.semiBold),
                                Text(
                                  '${aluno.apelido.isNotEmpty ? '"${aluno.apelido}" · ' : ''}${aluno.curso.displayName} ${aluno.turmaAno}'
                                  ' · ${formatarQuantidadeAvaliacoes(item.quantidadeAvaliacoes)}',
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: scheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formatarPontuacao(item),
                              style: context.textStyles.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.goNamed(AppRouteNames.ranking,
                          queryParameters: {'aba': 'global'}),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Ver ranking completo'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: AppSpacing.paddingMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: context.textStyles.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
