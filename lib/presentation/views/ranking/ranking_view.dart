import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/ranking_entity.dart';
import '../../../presentation/controllers/ranking_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pontuacao_format.dart';

/// Rankings Pessoal e Global (abas). [abaInicial]: 0 = Pessoal, 1 = Global.
class RankingView extends StatefulWidget {
  final int abaInicial;
  const RankingView({super.key, this.abaInicial = 0});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  late final RankingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<RankingViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.commands.carregarRankingPessoal();
      _vm.commands.carregarRankingGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = _vm.rankingState;
    return DefaultTabController(
      length: 2,
      initialIndex: widget.abaInicial.clamp(0, 1),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 Ranking'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.person_rounded), text: 'Pessoal'),
            Tab(icon: Icon(Icons.public_rounded), text: 'Global'),
          ]),
        ),
        drawer: const AppDrawer(),
        body: TabBarView(children: [
          Watch((_) => _RankingAba(
                pergunta: 'Na minha opinião, quem possui o maior Nível Lenda?',
                descricao: 'Considera apenas as avaliações feitas por você.',
                itens: st.rankingPessoal.value,
                carregando: st.carregandoPessoal.value,
                erro: st.erroPessoal.value,
                global: false,
                mensagemVazio: 'Você ainda não avaliou ninguém.\n'
                    'Avalie pessoas para montar seu ranking pessoal!',
                onRecarregar: _vm.commands.carregarRankingPessoal,
              )),
          Watch((_) => _RankingAba(
                pergunta: 'Na opinião dos usuários do aplicativo, quem possui o maior Nível Lenda?',
                descricao: 'Média das avaliações recebidas de todos os usuários.',
                itens: st.rankingGlobal.value,
                carregando: st.carregandoGlobal.value,
                erro: st.erroGlobal.value,
                global: true,
                mensagemVazio: 'Nenhuma avaliação registrada ainda.\n'
                    'O ranking global aparece após as primeiras avaliações.',
                onRecarregar: _vm.commands.carregarRankingGlobal,
              )),
        ]),
      ),
    );
  }
}

class _RankingAba extends StatelessWidget {
  final String pergunta;
  final String descricao;
  final List<ItemRanking> itens;
  final bool carregando;
  final String? erro;
  final bool global;
  final String mensagemVazio;
  final Future<void> Function() onRecarregar;

  const _RankingAba({
    required this.pergunta,
    required this.descricao,
    required this.itens,
    required this.carregando,
    required this.erro,
    required this.global,
    required this.mensagemVazio,
    required this.onRecarregar,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando && itens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erro != null && itens.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        message: erro!,
        actionLabel: 'Tentar novamente',
        onAction: onRecarregar,
      );
    }
    if (itens.isEmpty) {
      return EmptyState(
        icon: Icons.leaderboard_rounded,
        message: mensagemVazio,
        actionLabel: 'Ver pessoas',
        onAction: () => context.goNamed(AppRouteNames.alunos),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: onRecarregar,
      child: ListView(
        padding: AppSpacing.paddingMd,
        children: [
          Text(pergunta, style: context.textStyles.titleSmall?.semiBold),
          Text(descricao,
              style: context.textStyles.bodySmall
                  ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: AppSpacing.lg),
          _PodioSection(ranking: itens, global: global),
          const SizedBox(height: AppSpacing.xl),
          if (itens.length > 3) ...[
            Text('Demais posições', style: context.textStyles.titleMedium?.semiBold),
            const SizedBox(height: AppSpacing.md),
            ...itens.skip(3).map((item) => _RankingItem(
                  item: item,
                  global: global,
                  onTap: () => context.goNamed(
                    AppRouteNames.alunoDetalhe,
                    pathParameters: {'id': item.pessoa.id},
                  ),
                )),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Pódio ──────────────────────────────────────────────────────────────────
// Medalha pela posição (empates compartilham a medalha).
(String, Color) _medalha(int posicao) => switch (posicao) {
      1 => ('🥇', const Color(0xFFFFD700)),
      2 => ('🥈', const Color(0xFFC0C0C0)),
      _ => ('🥉', const Color(0xFFCD7F32)),
    };

class _PodioSection extends StatelessWidget {
  final List<ItemRanking> ranking;
  final bool global;
  const _PodioSection({required this.ranking, required this.global});

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
                  ? _PodioCard(item: top2, global: global, extraTopPadding: 0)
                  : const SizedBox(),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 1º lugar — espaço extra no topo para parecer mais alto
            Expanded(
              child: _PodioCard(item: top1, global: global, extraTopPadding: 40),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 3º lugar
            Expanded(
              child: top3 != null
                  ? _PodioCard(item: top3, global: global, extraTopPadding: 0)
                  : const SizedBox(),
            ),
          ],
        ),
      ],
    );
  }
}

class _PodioCard extends StatelessWidget {
  final ItemRanking item;
  final bool global;
  // Padding extra no topo faz o 1º lugar parecer maior sem forçar altura
  final double extraTopPadding;

  const _PodioCard({
    required this.item,
    required this.global,
    this.extraTopPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final pessoa = item.pessoa;
    final (emoji, medalColor) = _medalha(item.posicao);
    return GestureDetector(
      onTap: () => context.goNamed(
        AppRouteNames.alunoDetalhe,
        pathParameters: {'id': pessoa.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: medalColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: medalColor.withValues(alpha: 0.5), width: 2),
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
              backgroundColor: medalColor.withValues(alpha: 0.3),
              child: Text(
                pessoa.nome[0].toUpperCase(),
                style: TextStyle(
                  color: medalColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pessoa.nome.split(' ').first,
              style: context.textStyles.bodySmall?.semiBold,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            if (pessoa.apelido.isNotEmpty)
              Text(
                '"${pessoa.apelido}"',
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
                color: medalColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatarPontuacao(item),
                style: TextStyle(
                  color: medalColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            if (global) ...[
              const SizedBox(height: 2),
              Text(
                formatarQuantidadeAvaliacoes(item.quantidadeAvaliacoes),
                style: context.textStyles.bodySmall?.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Item de ranking (4+) ──────────────────────────────────────────────────
class _RankingItem extends StatelessWidget {
  final ItemRanking item;
  final bool global;
  final VoidCallback onTap;

  const _RankingItem({
    required this.item,
    required this.global,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pessoa = item.pessoa;

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
                  '${item.posicao}°',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.45),
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
                  pessoa.nome[0].toUpperCase(),
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
                    Text(pessoa.nome,
                        style: context.textStyles.titleSmall?.semiBold,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${pessoa.curso.displayName} · ${pessoa.turmaAno}'
                      '${pessoa.apelido.isNotEmpty ? ' · "${pessoa.apelido}"' : ''}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (global)
                      Text(
                        formatarQuantidadeAvaliacoes(item.quantidadeAvaliacoes),
                        style: context.textStyles.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
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
                  formatarPontuacao(item),
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
