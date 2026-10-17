import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/avaliacao_entity.dart';

/// Explica por que o usuário não pode avaliar (conta sem vínculo ou autoavaliação).
class AvisoAvaliacao extends StatelessWidget {
  final PermissaoAvaliacao permissao;
  const AvisoAvaliacao({super.key, required this.permissao});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icone, titulo, texto) = switch (permissao) {
      PermissaoAvaliacao.semVinculo => (
          Icons.link_off_rounded,
          'Conta ainda não vinculada',
          'Para avaliar, sua conta precisa estar vinculada a uma pessoa '
              'cadastrada no app, comprovando sua identidade. Esse vínculo é '
              'feito pelo administrador — peça a ele para vincular sua conta.',
        ),
      PermissaoAvaliacao.autoavaliacao => (
          Icons.person_off_rounded,
          'Este é o seu perfil',
          'Você não pode avaliar a si mesmo. Avalie outras pessoas!',
        ),
      PermissaoAvaliacao.permitida => (Icons.check_circle_outline, '', ''),
    };

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icone, color: scheme.secondary, size: 32),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: context.textStyles.titleMedium?.semiBold),
            const SizedBox(height: AppSpacing.xs),
            Text(texto,
                style: context.textStyles.bodySmall
                    ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7))),
          ]),
        ),
      ]),
    );
  }
}
