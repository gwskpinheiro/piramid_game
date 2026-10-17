import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../../presentation/controllers/pessoa_viewmodel.dart';

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
  Pessoa? _original;
  bool _isSaving = false;
  bool _loaded = false;

  bool get isEditing => widget.alunoId != null;

  late final PessoaViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<PessoaViewModel>();
    if (isEditing) {
      _carregarPessoa();
    } else {
      _loaded = true;
    }
  }

  Future<void> _carregarPessoa() async {
    Pessoa? p;
    try {
      p = _vm.pessoaState.pessoas.value.firstWhere((a) => a.id == widget.alunoId);
    } catch (_) {
      // Não está em memória (ex.: link direto) — busca no Firestore.
      p = await _vm.commands.buscarPessoaPorId(widget.alunoId!);
    }
    if (!mounted) return;
    if (p != null) {
      _original = p;
      _nomeCtrl.text = p.nome;
      _apelidoCtrl.text = p.apelido;
      _cursoSelecionado = p.curso;
      _turmaSelecionada = p.turmaAno;
      _dataNascimento = p.dataNascimento;
    }
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
    final pessoa = Pessoa(
      id: _original?.id ?? '',
      nome: _nomeCtrl.text.trim(),
      apelido: _apelidoCtrl.text.trim(),
      curso: _cursoSelecionado,
      turmaAno: _turmaSelecionada,
      dataNascimento: _dataNascimento,
      criadoPor: _original?.criadoPor ?? '', // no cadastro, definido no use case
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final ok = isEditing
        ? await _vm.commands.atualizarPessoa(pessoa)
        : await _vm.commands.cadastrarPessoa(pessoa);

    if (!mounted) return;
    setState(() => _isSaving = false);

    final msg = ok
        ? (isEditing ? '✅ Aluno atualizado com sucesso!' : '✅ Aluno cadastrado com sucesso!')
        : (_vm.pessoaState.mensagem.value ?? 'Não foi possível salvar.');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (ok) context.goNamed(AppRouteNames.alunos);
  }

  @override
  Widget build(BuildContext context) {
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
      body: isEditing && _original == null
          ? const Center(child: Text('Aluno não encontrado.'))
          : Form(
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
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'O nome é obrigatório.' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _apelidoCtrl,
              decoration: const InputDecoration(
                labelText: 'Apelido',
                hintText: 'Apelido ou nome popular',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.sm),

            DropdownButtonFormField<Curso>(
              initialValue: _cursoSelecionado,
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
              initialValue: _turmaSelecionada,
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) =>
      Text(title, style: context.textStyles.titleLarge?.semiBold);
}
