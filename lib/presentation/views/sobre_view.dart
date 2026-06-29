import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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
                  'O Ranking de Popularidade dos Alunos é um aplicativo '
                  'desenvolvido em Flutter para fins didáticos. Ele permite '
                  'cadastrar alunos do IFPR – Campus Paranaguá e avaliá-los '
                  'em critérios descontraídos de convivência, destaque e '
                  'participação na turma.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.school_outlined,
              title: 'Contexto',
              content:
                  'O app nasceu de uma ideia divertida entre alunos do IFPR – '
                  'Campus Paranaguá, que decidiram criar um sistema para '
                  'ranquear os colegas por popularidade, carisma, presença e '
                  'outros talentos socialmente valorizados nos corredores do campus.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.star_outline_rounded,
              title: 'Como funciona o Ranking',
              content:
                  'Cada aluno é avaliado em 15 critérios de popularidade, '
                  'recebendo notas de 1 a 5 estrelas em cada um. '
                  'A soma de todas as notas forma o Nível Lenda, '
                  'que varia de 15 (mínimo) a 75 (máximo) pontos. '
                  'O ranking é ordenado automaticamente do maior para o menor Nível Lenda.',
            ),

            const SizedBox(height: AppSpacing.md),

            // Lista de critérios
            _CriteriosCard(),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.storage_outlined,
              title: 'Armazenamento de Dados',
              content:
                  'Todos os dados são armazenados localmente no dispositivo '
                  'utilizando SharedPreferences. Os dados permanecem salvos '
                  'mesmo após fechar o aplicativo.',
            ),

            const SizedBox(height: AppSpacing.md),

            _InfoCard(
              icon: Icons.brightness_6_outlined,
              title: 'Tema Claro e Escuro',
              content:
                  'O aplicativo suporta alternância entre tema claro e tema '
                  'escuro em tempo de execução. Acesse a opção pelo menu '
                  'lateral ou pelo ícone na barra superior.',
            ),

            const SizedBox(height: AppSpacing.md),

            // Tecnologias
            _InfoCard(
              icon: Icons.code_rounded,
              title: 'Tecnologias',
              content:
                  '• Flutter (framework principal)\n'
                  '• SharedPreferences (armazenamento local)\n'
                  '• go_router (navegação)\n'
                  '• Flutter Signals (gerência de estado reativa)\n'
                  '• Padrão MVVM + Command + Result\n'
                  '• Arquitetura Limpa (Clean Architecture)\n'
                  '• Princípios SOLID',
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

    final criterios = [
      '1. Resenha', '2. Presença VIP', '3. Aura', '4. Modo Parceiro',
      '5. Carisma Natural', '6. Humor de Milhões', '7. Energia de Grupo',
      '8. Criatividade Caótica', '9. Modo Atleta', '10. Talento de Palco',
      '11. Drip Escolar', '12. Coração de Dorama',
      '13. Queridinho dos Professores', '14. Cérebro Turbo',
      '15. Caos Controlado',
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
