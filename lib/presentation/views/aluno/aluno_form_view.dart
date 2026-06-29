import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/aluno_entity.dart';
import '../../../presentation/controllers/aluno_viewmodel.dart';
import '../../widgets/star_rating.dart';

class AlunoFormView extends StatefulWidget {
  /// Se [alunoId] for null, é cadastro. Senão, é edição.
  final String? alunoId;

  const AlunoFormView({super.key, required this.alunoId});

  @override
  State<AlunoFormView> createState() => _AlunoFormViewState();
}

class _AlunoFormViewState extends State<AlunoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _apelidoCtrl = TextEditingController();

  Curso _cursoSelecionado = Curso.tads;
  int _turmaSelecionada = 2024;
  DateTime _dataNascimento = DateTime(2000, 1, 1);
  CriteriosPopularidade _criterios = const CriteriosPopularidade();
  bool _isSaving = false;
  bool _loaded = false;

  bool get isEditing => widget.alunoId != null;

  late final AlunoViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AlunoViewModel>();
    if (isEditing) {
      _carregarAluno();
    } else {
      _loaded = true;
    }
  }

  void _carregarAluno() {
    final alunos = _vm.alunoState.alunos.value;
    try {
      final a = alunos.firstWhere((a) => a.id == widget.alunoId);
      _nomeCtrl.text = a.nome;
      _apelidoCtrl.text = a.apelido;
      _cursoSelecionado = a.curso;
      _turmaSelecionada = a.turmaAno;
      _dataNascimento = a.dataNascimento;
      _criterios = a.criterios;
    } catch (_) {}
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _apelidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: 'Data de Nascimento',
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    Aluno? alunoOriginal;
    if (isEditing) {
      try {
        alunoOriginal = _vm.alunoState.alunos.value
            .firstWhere((a) => a.id == widget.alunoId);
      } catch (_) {}
    }

    final alunoParaSalvar = Aluno(
      id: isEditing ? widget.alunoId! : '',
      nome: _nomeCtrl.text.trim(),
      apelido: _apelidoCtrl.text.trim(),
      curso: _cursoSelecionado,
      turmaAno: _turmaSelecionada,
      dataNascimento: _dataNascimento,
      criterios: _criterios,
      createdAt: alunoOriginal?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEditing) {
      await _vm.commands.atualizarAluno(alunoParaSalvar);
    } else {
      await _vm.commands.cadastrarAluno(alunoParaSalvar);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? '✅ Aluno atualizado com sucesso!'
              : '✅ Aluno cadastrado com sucesso!'),
        ),
      );
      context.goNamed(AppRouteNames.alunos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Aluno' : 'Novo Aluno'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.goNamed(AppRouteNames.alunos),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            _SectionHeader(title: '📋 Dados Básicos'),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                hintText: 'Nome completo do aluno',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'O nome é obrigatório.' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _apelidoCtrl,
              decoration: const InputDecoration(
                labelText: 'Apelido',
                hintText: 'Apelido ou nome popular',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<Curso>(
              value: _cursoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Curso *',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              items: Curso.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _cursoSelecionado = v!),
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<int>(
              value: _turmaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Turma/Ano *',
                prefixIcon: Icon(Icons.calendar_view_month),
                border: OutlineInputBorder(),
              ),
              items: List.generate(2026 - 1998 + 1, (i) => 2026 - i)
                  .map((ano) => DropdownMenuItem(value: ano, child: Text('$ano')))
                  .toList(),
              onChanged: (v) => setState(() => _turmaSelecionada = v!),
            ),
            const SizedBox(height: AppSpacing.md),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento *',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit_calendar_outlined),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_dataNascimento)),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(title: '⭐ Critérios de Popularidade'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Avalie cada critério de 1 a 5 estrelas.',
              style: context.textStyles.bodySmall
                  ?.copyWith(color: scheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: AppSpacing.md),

            ..._buildCriterioWidgets(scheme),

            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nível Lenda',
                          style: context.textStyles.titleSmall
                              ?.copyWith(color: Colors.white)),
                      Text('Pontuação total',
                          style: context.textStyles.bodySmall
                              ?.copyWith(color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                  Text(
                    '${_criterios.nivelLenda} pts',
                    style: context.textStyles.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _salvar,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Salvar Alterações' : 'Cadastrar Aluno'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCriterioWidgets(ColorScheme scheme) {
    final nomes = [
      'Resenha', 'Presença VIP', 'Aura', 'Modo Parceiro',
      'Carisma Natural', 'Humor de Milhões', 'Energia de Grupo',
      'Criatividade Caótica', 'Modo Atleta', 'Talento de Palco',
      'Drip Escolar', 'Coração de Dorama', 'Queridinho dos Professores',
      'Cérebro Turbo', 'Caos Controlado',
    ];

    final valores = [
      _criterios.resenha, _criterios.presencaVip, _criterios.aura,
      _criterios.modoParceiro, _criterios.carisma, _criterios.humorMilhoes,
      _criterios.energiaGrupo, _criterios.criatividadeCaotica,
      _criterios.modoAtleta, _criterios.talentopalco, _criterios.dripEscolar,
      _criterios.coracaoDorama, _criterios.queridinhoProf,
      _criterios.cerebroTurbo, _criterios.caosControlado,
    ];

    return List.generate(15, (i) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: scheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. ${nomes[i]}',
                      style: context.textStyles.titleSmall?.medium),
                  const SizedBox(height: 4),
                  Text(
                    listaCriterios[i].$2,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              children: [
                StarRating(
                  stars: valores[i],
                  size: 26,
                  interactive: true,
                  onChanged: (v) => setState(() {
                    _criterios = _updateCriterio(i, v);
                  }),
                ),
                Text('${valores[i]}/5',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.5),
                    )),
              ],
            ),
          ],
        ),
      );
    });
  }

  CriteriosPopularidade _updateCriterio(int index, int value) {
    return _criterios.copyWith(
      resenha: index == 0 ? value : null,
      presencaVip: index == 1 ? value : null,
      aura: index == 2 ? value : null,
      modoParceiro: index == 3 ? value : null,
      carisma: index == 4 ? value : null,
      humorMilhoes: index == 5 ? value : null,
      energiaGrupo: index == 6 ? value : null,
      criatividadeCaotica: index == 7 ? value : null,
      modoAtleta: index == 8 ? value : null,
      talentopalco: index == 9 ? value : null,
      dripEscolar: index == 10 ? value : null,
      coracaoDorama: index == 11 ? value : null,
      queridinhoProf: index == 12 ? value : null,
      cerebroTurbo: index == 13 ? value : null,
      caosControlado: index == 14 ? value : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) =>
      Text(title, style: context.textStyles.titleLarge?.semiBold);
}
