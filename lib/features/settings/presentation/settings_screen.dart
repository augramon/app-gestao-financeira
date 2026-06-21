import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import 'theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          _Header('Tema'),
          _ThemeOption(
            label: 'Claro',
            icon: Icons.light_mode_outlined,
            value: ThemeMode.light,
            selected: mode,
            onSelect: controller.setThemeMode,
          ),
          _ThemeOption(
            label: 'Escuro',
            icon: Icons.dark_mode_outlined,
            value: ThemeMode.dark,
            selected: mode,
            onSelect: controller.setThemeMode,
          ),
          _ThemeOption(
            label: 'Do sistema',
            icon: Icons.brightness_auto_outlined,
            value: ThemeMode.system,
            selected: mode,
            onSelect: controller.setThemeMode,
          ),
          const Divider(),
          _Header('Preferências'),
          const ListTile(
            leading: Icon(Icons.attach_money_rounded),
            title: Text('Moeda'),
            subtitle: Text('Real brasileiro (BRL)'),
          ),
          const Divider(),
          _Header('Sobre'),
          AboutListTile(
            icon: const Icon(Icons.info_outline_rounded),
            applicationName: AppConstants.appName,
            applicationVersion: AppConstants.appVersion,
            applicationLegalese: '© 2026 ${AppConstants.appName}',
            child: const Text('Sobre o app'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de privacidade'),
            onTap: () =>
                _showDoc(context, 'Política de privacidade', _privacyText),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Termos de uso'),
            onTap: () => _showDoc(context, 'Termos de uso', _termsText),
          ),
        ],
      ),
    );
  }

  void _showDoc(BuildContext context, String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () => onSelect(value),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingXs,
      ),
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

const _privacyText =
    'Este é um texto fictício de política de privacidade para fins de MVP. '
    'O ${AppConstants.appName} armazena seus dados de gastos e perfil de forma '
    'privada e associada apenas à sua conta. Nenhum dado é compartilhado com '
    'terceiros. Você pode excluir sua conta e seus dados a qualquer momento.';

const _termsText =
    'Este é um texto fictício de termos de uso para fins de MVP. '
    'Ao utilizar o ${AppConstants.appName}, você concorda em usar o aplicativo '
    'apenas para controle financeiro pessoal. O serviço é fornecido "como está", '
    'sem garantias, no contexto de um MVP educacional.';
