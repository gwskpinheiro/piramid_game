import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/aluno_entity.dart';
import '../../../presentation/controllers/aluno_viewmodel.dart';
import '../../widgets/star_rating.dart';

class AlunoDetalheView extends StatefulWidget {
  final String alunoId;
  const AlunoDetalheView({super.key, required this.alunoId});

  @override
  State<AlunoDetalheView> createState() => _AlunoDetalheViewState();
}

class _AlunoDetalheViewState extends State<AlunoDetalheView> {
  late final AlunoViewModel _vm;
  Aluno? _aluno;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AlunoViewModel>();
    _buscar();
  }

  Future<void> _buscar() async {
    // Tenta primeiro na lista em memória (mais rápido)
    final emMemoria = _vm.alunoState.alunos.value;
    if (emMemoria.isNotEmpty) {
      try {
        final encontrado = emMemoria.firstWhere((a) => a.id == widget.alunoId);
        setState(() { _aluno = encontrado; _loading = false; });
        return;
      } catch (_) {}
    }
    // Se não encontrou em memória, busca pelo use case (buscar por identificador)
    final aluno = await _vm.commands.buscarAlunoPorId(widget.alunoId);
    setState(() { _aluno = aluno; _loading = false; });
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
        body: const Center(child: Text('Aluno não encontrado.')),
      );
    }

    final aluno = _aluno!;

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
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
            onPressed: () => context.goNamed(
              'aluno_form_edit',
              pathParameters: {'id': aluno.id},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(aluno: aluno),
            const SizedBox(height: AppSpacing.lg),
            _NivelLendaCard(aluno: aluno),
            const SizedBox(height: AppSpacing.lg),
            Text('⭐ Critérios de Popularidade',
                style: context.textStyles.titleLarge?.semiBold),
            const SizedBox(height: AppSpacing.md),
            _CriteriosList(criterios: aluno.criterios),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cadastrado em: ${DateFormat('dd/MM/yyyy HH:mm').format(aluno.createdAt)}',
              style: context.textStyles.bodySmall
                  ?.copyWith(color: scheme.onSurface.withOpacity(0.5)),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Aluno aluno;
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

class _NivelLendaCard extends StatelessWidget {
  final Aluno aluno;
  const _NivelLendaCard({required this.aluno});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pontos = aluno.nivelLenda;
    final percent = (pontos - 15) / (75 - 15);

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🏆 Nível Lenda',
                    style: context.textStyles.titleMedium?.semiBold),
                Text('Pontuação Total',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    )),
              ]),
              Text('$pontos pts',
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: scheme.primary, fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: scheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15 pts (mín)',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: scheme.onSurface.withOpacity(0.5))),
              Text('75 pts (máx)',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: scheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriteriosList extends StatelessWidget {
  final CriteriosPopularidade criterios;
  const _CriteriosList({required this.criterios});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nomes = [
      'Resenha', 'Presença VIP', 'Aura', 'Modo Parceiro',
      'Carisma Natural', 'Humor de Milhões', 'Energia de Grupo',
      'Criatividade Caótica', 'Modo Atleta', 'Talento de Palco',
      'Drip Escolar', 'Coração de Dorama', 'Queridinho dos Professores',
      'Cérebro Turbo', 'Caos Controlado',
    ];
    final valores = [
      criterios.resenha, criterios.presencaVip, criterios.aura,
      criterios.modoParceiro, criterios.carisma, criterios.humorMilhoes,
      criterios.energiaGrupo, criterios.criatividadeCaotica,
      criterios.modoAtleta, criterios.talentopalco, criterios.dripEscolar,
      criterios.coracaoDorama, criterios.queridinhoProf,
      criterios.cerebroTurbo, criterios.caosControlado,
    ];

    return Column(
      children: List.generate(15, (i) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Expanded(child: Text('${i + 1}. ${nomes[i]}',
                style: context.textStyles.titleSmall)),
            StarRating(stars: valores[i], size: 20),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 30,
              child: Text('${valores[i]}/5',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: scheme.primary, fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      )),
    );
  }
}
