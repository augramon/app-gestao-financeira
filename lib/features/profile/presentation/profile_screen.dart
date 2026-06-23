import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../settings/presentation/theme_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Sair da conta',
      message: 'Deseja realmente sair?',
      confirmLabel: 'Sair',
    );
    if (!confirm) return;
    await ref.read(authControllerProvider.notifier).signOut();
    // O GoRouter redireciona para o login automaticamente.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(appUserProvider);
    final user = userAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          // Cabeçalho do usuário.
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  user == null || user.name.isEmpty
                      ? '?'
                      : user.name.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '—',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Membro desde ${DateFilterUtils.formatDate(user.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMd),
          const _StatTile(),
          const SizedBox(height: AppConstants.spacingLg),
          const Divider(),

          // Aparência (tema).
          _SectionTitle('Aparência'),
          const _ThemeSelector(),

          const SizedBox(height: AppConstants.spacingMd),
          const Divider(),
          _SectionTitle('Conta'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.settings),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text(
              'Sair',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends ConsumerWidget {
  const _StatTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countAsync = ref.watch(totalExpenseCountProvider);
    final count = countAsync.value;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              'Gastos cadastrados',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            count == null ? '—' : '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeControllerProvider);
    final platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformDark,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              isDark ? 'Tema escuro' : 'Tema claro',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const ThemeToggle(),
        ],
      ),
    );
  }
}
