import 'package:flutter/material.dart';

/// Item de um [SegmentedToggle].
class SegmentItem<T> {
  const SegmentItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Abas segmentadas de seleção única, no estilo "tabs" do shadcn/ui
/// (variante `default`): um trilho de fundo onde a aba ativa aparece como
/// uma pílula clara, com sombra sutil, que desliza ao trocar de seleção.
///
/// Selecionar uma aba desmarca automaticamente a anterior — só uma fica
/// ativa por vez. Passe `value: null` para não destacar nenhuma.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.height = 40,
  });

  /// Opções exibidas, da esquerda para a direita.
  final List<SegmentItem<T>> segments;

  /// Valor atualmente selecionado (ou `null` para nenhum).
  final T? value;

  /// Disparado quando o usuário toca em uma aba.
  final ValueChanged<T> onChanged;

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Trilho de fundo (equivalente ao `bg-accent p-1 rounded-lg`).
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : colors.onSurface.withValues(alpha: 0.05);
    // Pílula da aba ativa (equivalente ao `data-[state=active]:bg-background`).
    final pillColor = isDark ? const Color(0xFF2A2E31) : Colors.white;

    const padding = 4.0;
    const radius = 12.0;
    final selectedIndex = value == null
        ? -1
        : segments.indexWhere((s) => s.value == value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final segWidth =
            (constraints.maxWidth - padding * 2) / segments.length;

        return Container(
          height: height,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Stack(
            children: [
              // Indicador deslizante: a "aba" ativa.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: selectedIndex < 0 ? 0 : selectedIndex * segWidth,
                top: 0,
                bottom: 0,
                width: segWidth,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: selectedIndex < 0 ? 0 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(radius - padding),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Rótulos clicáveis sobre o trilho.
              Positioned.fill(
                child: Row(
                  children: [
                    for (final seg in segments)
                      Expanded(
                        child: _SegmentLabel(
                          label: seg.label,
                          selected: seg.value == value,
                          onTap: () => onChanged(seg.value),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colors.onSurface : colors.onSurfaceVariant,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
