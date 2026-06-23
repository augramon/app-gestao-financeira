import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/theme_controller.dart';

/// Alternador de tema (claro/escuro) em formato de pílula deslizante.
///
/// Réplica em Flutter do componente shadcn/Tailwind `theme-toggle`:
/// pílula 64×32 arredondada, com um "knob" circular que desliza e troca
/// entre os ícones de lua (escuro) e sol (claro). Ligado ao
/// [themeControllerProvider], que persiste a escolha localmente.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  // Paleta equivalente às classes Tailwind do componente original.
  static const _zinc950 = Color(0xFF09090B); // bg escuro
  static const _zinc800 = Color(0xFF27272A); // borda/knob escuro
  static const _zinc200 = Color(0xFFE4E4E7); // borda claro
  static const _gray200 = Color(0xFFE5E7EB); // knob claro
  static const _gray700 = Color(0xFF374151); // sol no knob claro
  static const _gray500 = Color(0xFF6B7280); // sol apagado (escuro)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    final platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformDark,
    };

    void toggle() =>
        controller.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);

    const duration = Duration(milliseconds: 300);

    return Semantics(
      button: true,
      label: isDark ? 'Mudar para tema claro' : 'Mudar para tema escuro',
      child: GestureDetector(
        onTap: toggle,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          width: 64,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? _zinc950 : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isDark ? _zinc800 : _zinc200),
          ),
          child: Stack(
            children: [
              // Ícone "apagado" do lado oposto ao knob.
              AnimatedAlign(
                duration: duration,
                curve: Curves.easeInOut,
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 16,
                  color: isDark ? _gray500 : Colors.black,
                ),
              ),
              // Knob ativo, que desliza entre os lados.
              AnimatedAlign(
                duration: duration,
                curve: Curves.easeInOut,
                alignment:
                    isDark ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? _zinc800 : _gray200,
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    size: 16,
                    color: isDark ? Colors.white : _gray700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
