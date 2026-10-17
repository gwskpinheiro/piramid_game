import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/avaliacao_entity.dart';
import '../../controllers/avaliacao_viewmodel.dart';
import '../../controllers/pessoa_viewmodel.dart';
import '../../widgets/aviso_avaliacao.dart';
import '../../widgets/star_rating.dart';

/// Tela para registrar ou alterar a avaliação do usuário autenticado
/// sobre uma pessoa, nos 15 critérios de popularidade.
class AvaliacaoView extends StatefulWidget {
  final String pessoaId;
  const AvaliacaoView({super.key, required this.pessoaId});

  @override
  State<AvaliacaoView> createState() => _AvaliacaoViewState();
}

class _AvaliacaoViewState extends State<AvaliacaoView> {
  late final AvaliacaoViewModel _vm;
  late final PessoaViewModel _pessoaVm;
  String _nomePessoa = '';

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AvaliacaoViewModel>();
    _pessoaVm = injector.get<PessoaViewModel>();
    // Após o primeiro frame: alterar os signals compartilhados durante o build
    // dispara o Watch da tela anterior (já desativada) e aborta o carregamento.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _carregarNome();
      _vm.commands.carregar(widget.pessoaId);
    });
  }

  Future<void> _carregarNome() async {
    final emMemoria = _pessoaVm.pessoaState.pessoas.value
        .where((p) => p.id == widget.pessoaId);
    final pessoa = emMemoria.isNotEmpty
        ? emMemoria.first
        : await _pessoaVm.commands.buscarPessoaPorId(widget.pessoaId);
    if (mounted && pessoa != null) setState(() => _nomePessoa = pessoa.nome);
  }

  void _voltar() => context.canPop()
      ? context.pop()
      : context.goNamed(AppRouteNames.alunoDetalhe, pathParameters: {'id': widget.pessoaId});

  Future<void> _salvar() async {
    final editando = _vm.avaliacaoState.jaAvaliou.value;
    final ok = await _vm.commands.salvar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? (editando ? '✅ Avaliação atualizada!' : '✅ Avaliação registrada!')
          : (_vm.avaliacaoState.mensagem.value ?? 'Não foi possível salvar a avaliação.')),
    ));
    if (ok) _voltar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Watch((_) => Text(_vm.avaliacaoState.jaAvaliou.value
            ? 'Editar Avaliação'
            : 'Avaliar')),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _voltar),
      ),
      body: Watch((_) {
        final st = _vm.avaliacaoState;
        // Estado ainda de outra pessoa (antes do carregamento começar) conta como carregando.
        if (st.isLoading.value || st.pessoaId.value != widget.pessoaId) {
          return const Center(child: CircularProgressIndicator());
        }
        final erro = st.erroCarregamento.value;
        final permissao = st.permissao.value;
        if (erro != null || permissao == null) {
          return _ErroCarregamento(
            mensagem: erro ??
                'Não foi possível verificar se você pode avaliar esta pessoa.',
            onTentarNovamente: () => _vm.commands.carregar(widget.pessoaId),
          );
        }
        if (permissao != PermissaoAvaliacao.permitida) {
          return ListView(padding: AppSpacing.paddingMd, children: [
            AvisoAvaliacao(permissao: permissao),
          ]);
        }
        return _FormularioAvaliacao(
          nomePessoa: _nomePessoa,
          criterios: st.criterios.value,
          nivelLenda: st.nivelLenda.value,
          editando: st.jaAvaliou.value,
          salvando: st.isSaving.value,
          onChanged: _vm.commands.alterarNota,
          onSalvar: _salvar,
        );
      }),
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;
  const _ErroCarregamento({required this.mensagem, required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: scheme.error.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.md),
          Text(mensagem,
              textAlign: TextAlign.center,
              style: context.textStyles.titleSmall
                  ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.75))),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onTentarNovamente,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ]),
      ),
    );
  }
}

class _FormularioAvaliacao extends StatelessWidget {
  final String nomePessoa;
  final CriteriosPopularidade criterios;
  final int nivelLenda;
  final bool editando;
  final bool salvando;
  final ValueChanged<CriteriosPopularidade> onChanged;
  final VoidCallback onSalvar;

  const _FormularioAvaliacao({
    required this.nomePessoa,
    required this.criterios,
    required this.nivelLenda,
    required this.editando,
    required this.salvando,
    required this.onChanged,
    required this.onSalvar,
  });

  List<int> get _valores => [
    criterios.resenha, criterios.presencaVip, criterios.aura,
    criterios.modoParceiro, criterios.carisma, criterios.humorMilhoes,
    criterios.energiaGrupo, criterios.criatividadeCaotica,
    criterios.modoAtleta, criterios.talentopalco, criterios.dripEscolar,
    criterios.coracaoDorama, criterios.queridinhoProf,
    criterios.cerebroTurbo, criterios.caosControlado,
  ];

  CriteriosPopularidade _comNota(int i, int v) => criterios.copyWith(
    resenha: i == 0 ? v : null,
    presencaVip: i == 1 ? v : null,
    aura: i == 2 ? v : null,
    modoParceiro: i == 3 ? v : null,
    carisma: i == 4 ? v : null,
    humorMilhoes: i == 5 ? v : null,
    energiaGrupo: i == 6 ? v : null,
    criatividadeCaotica: i == 7 ? v : null,
    modoAtleta: i == 8 ? v : null,
    talentopalco: i == 9 ? v : null,
    dripEscolar: i == 10 ? v : null,
    coracaoDorama: i == 11 ? v : null,
    queridinhoProf: i == 12 ? v : null,
    cerebroTurbo: i == 13 ? v : null,
    caosControlado: i == 14 ? v : null,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valores = _valores;

    return ListView(
      padding: AppSpacing.paddingMd,
      children: [
        Text('⭐ Critérios de Popularidade', style: context.textStyles.titleLarge?.semiBold),
        const SizedBox(height: AppSpacing.xs),
        Text(
          nomePessoa.isEmpty
              ? 'Avalie cada critério de 1 a 5 estrelas.'
              : 'Avalie $nomePessoa em cada critério de 1 a 5 estrelas.',
          style: context.textStyles.bodySmall
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: AppSpacing.md),

        ...List.generate(15, (i) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${i + 1}. ${listaCriterios[i].$1}',
                    style: context.textStyles.titleSmall?.medium),
                const SizedBox(height: 4),
                Text(listaCriterios[i].$2,
                    style: context.textStyles.bodySmall
                        ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.55))),
              ]),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(children: [
              StarRating(
                stars: valores[i],
                size: 26,
                interactive: !salvando,
                onChanged: (v) => onChanged(_comNota(i, v)),
              ),
              Text('${valores[i]}/5',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5))),
            ]),
          ]),
        )),

        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary.withValues(alpha: 0.8)]),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nível Lenda',
                  style: context.textStyles.titleSmall?.copyWith(color: Colors.white)),
              Text('Pontuação total (15 a 75)',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
            ]),
            Text('$nivelLenda pts',
                style: context.textStyles.headlineSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ),

        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: salvando ? null : onSalvar,
            icon: salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(editando ? 'Salvar Alterações' : 'Registrar Avaliação'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
