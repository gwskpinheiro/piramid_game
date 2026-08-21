import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = injector.get<ThemeController>();
    final scheme = Theme.of(context).colorScheme;

    return Drawer(child: SafeArea(child: Column(children: [
      Container(
        width: double.infinity,
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [scheme.primary, scheme.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: scheme.onPrimary.withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.emoji_events_rounded, color: scheme.onPrimary, size: 36)),
          const SizedBox(height: AppSpacing.sm),
          Text('PiramidGame', style: context.textStyles.titleLarge?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold)),
          Text('IFPR – Campus Paranaguá', style: context.textStyles.bodySmall?.copyWith(color: scheme.onPrimary.withOpacity(0.8))),
        ]),
      ),
      const SizedBox(height: AppSpacing.sm),
      _DrawerItem(icon: Icons.home_rounded, label: 'Início', onTap: () { Navigator.pop(context); context.goNamed(AppRouteNames.home); }),
      _DrawerItem(icon: Icons.people_alt_rounded, label: 'Alunos', onTap: () { Navigator.pop(context); context.goNamed(AppRouteNames.alunos); }),
      _DrawerItem(icon: Icons.leaderboard_rounded, label: 'Ranking', onTap: () { Navigator.pop(context); context.goNamed(AppRouteNames.ranking); }),
      const Divider(height: AppSpacing.lg),
      _DrawerItem(icon: Icons.info_outline_rounded, label: 'Sobre o App', onTap: () { Navigator.pop(context); context.goNamed(AppRouteNames.sobre); }),
      const Spacer(),
      Watch((_) {
        final isLight = themeCtrl.isLightMode.value;
        return Padding(padding: AppSpacing.paddingMd, child: Row(children: [
          Icon(isLight ? Icons.light_mode : Icons.dark_mode, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(isLight ? 'Tema Claro' : 'Tema Escuro', style: context.textStyles.bodyMedium),
          const Spacer(),
          Switch(value: !isLight, activeColor: scheme.primary, onChanged: (_) => themeCtrl.toggleTheme()),
        ]));
      }),
      const SizedBox(height: AppSpacing.sm),
    ])));
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(label, style: context.textStyles.bodyLarge),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  );
}
