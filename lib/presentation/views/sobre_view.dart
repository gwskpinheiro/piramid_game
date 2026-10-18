import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../widgets/app_drawer.dart';

class SobreView extends StatelessWidget {
  const SobreView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
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
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      size: 60, color: Colors.white),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'PiramidGame',
                    style: context.textStyles.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ranking de Popularidade dos Alunos',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'IFPR – Campus Paranaguá',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _InfoCard(
              icon: Icons.info_outline,
              title: 'Objetivo do App',
              content:
                  'O PiramidGame IFPR-Pgua é um aplicativo desenvolvido em '
                  'Flutter para fins didáticos. Ele permite cadastrar pessoas '
                  'do IFPR – Campus Paranaguá e avaliá-las em critérios '
                  'descontraídos de convivência, destaque e participação.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.school_outlined,
              title: 'Contexto',
              content:
                  'O app nasceu de uma ideia divertida entre alunos do IFPR – '
                  'Campus Paranaguá para descobrir quem domina o Nível Lenda. '
                  'Com os dados na nuvem, todos participam do mesmo ranking, '
                  'e não de um ranking diferente em cada aparelho.',
            ),

            const SizedBox(height: AppSpacing.md),

            // Lista de critérios
            _CriteriosCard(),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.star_outline_rounded,
              title: 'Nível Lenda',
              content:
                  'A soma das 15 notas de uma avaliação forma o Nível Lenda, '
                  'que vai de 15 pontos (15 × 1 estrela) a 75 pontos '
                  '(15 × 5 estrelas).',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.person_rounded,
              title: 'Ranking Pessoal',
              content:
                  '“Na minha opinião, quem possui o maior Nível Lenda?”\n'
                  'Considera exclusivamente as avaliações feitas por você, '
                  'ordenadas da maior para a menor pontuação.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.public_rounded,
              title: 'Ranking Global',
              content:
                  '“Na opinião dos usuários do aplicativo, quem possui o maior '
                  'Nível Lenda?”\n'
                  'Considera as avaliações de todos os usuários: a pontuação '
                  'de cada pessoa é a média das avaliações recebidas, exibida '
                  'junto com a quantidade de avaliações.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.rule_rounded,
              title: 'Regras de Avaliação',
              content:
                  '• Ninguém pode avaliar a si próprio.\n'
                  '• Cada usuário tem uma única avaliação por pessoa, que pode '
                  'ser alterada depois.\n'
                  '• No primeiro acesso, você identifica seu próprio perfil: '
                  'escolhe-o entre as pessoas cadastradas ou cadastra o seu.\n'
                  '• Cada perfil pode ser vinculado a uma única conta, e o '
                  'vínculo não pode ser trocado depois.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.cloud_outlined,
              title: 'Login e Armazenamento',
              content:
                  'O acesso utiliza Firebase Authentication, com e-mail e '
                  'senha ou conta Google. Pessoas, avaliações e rankings ficam '
                  'no Cloud Firestore, então seus dados estão disponíveis em '
                  'qualquer aparelho em que você entrar com a mesma conta.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.brightness_6_outlined,
              title: 'Tema Claro e Escuro',
              content:
                  'Alterne entre tema claro e escuro pelo menu lateral ou pelo '
                  'ícone na barra superior. Sua escolha fica salva no aparelho '
                  'com SharedPreferences, usado apenas para essa preferência.',
            ),

            const SizedBox(height: AppSpacing.md),

            // Tecnologias
            _InfoCard(
              icon: Icons.code_rounded,
              title: 'Tecnologias',
              content:
                  '• Flutter\n'
                  '• Firebase Authentication e Cloud Firestore\n'
                  '• SharedPreferences (preferência de tema)\n'
                  '• go_router (navegação)\n'
                  '• Flutter Signals (estado reativo)\n'
                  '• MVVM, Command e Result\n'
                  '• Arquitetura Limpa e princípios SOLID',
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: context.textStyles.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: context.textStyles.bodyMedium?.copyWith(
              color: scheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriosCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Mesma lista usada na tela de avaliação.
    final criterios = [
      for (var i = 0; i < listaCriterios.length; i++) '${i + 1}. ${listaCriterios[i].$1}',
    ];

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered, color: scheme.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Os 15 Critérios',
                style: context.textStyles.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cada avaliação atribui de 1 a 5 estrelas em cada critério.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: criterios.map((c) => Chip(
              label: Text(
                c,
                style: context.textStyles.bodySmall,
              ),
              backgroundColor: scheme.primaryContainer.withOpacity(0.4),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ),
    );
  }
}
