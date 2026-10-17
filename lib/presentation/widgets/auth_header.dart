import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Cabeçalho com a identidade visual do app, usado nas telas de autenticação.
class AuthHeader extends StatelessWidget {
  final String subtitulo;
  const AuthHeader({super.key, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.secondary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events_rounded, size: 56, color: Colors.white),
      ),
      const SizedBox(height: AppSpacing.md),
      Text('PiramidGame',
          style: context.textStyles.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: AppSpacing.xs),
      Text(subtitulo,
          style: context.textStyles.bodyMedium
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
          textAlign: TextAlign.center),
    ]);
  }
}
