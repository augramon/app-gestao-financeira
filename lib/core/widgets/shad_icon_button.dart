import 'package:flutter/material.dart';

/// Botão de ícone no estilo shadcn/ui (`variant="outline" size="icon"`):
/// fundo claro, borda sutil (`border-input`), cantos arredondados
/// (`rounded-lg`), sombra suave (`shadow-sm`) e realce no hover
/// (`hover:bg-accent`). Quando [selected] é `true`, ganha um preenchimento
/// tonal e borda destacada — equivalente ao estado ativo de um toggle.
class ShadIconButton extends StatefulWidget {
  const ShadIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool selected;
  final double size;

  @override
  State<ShadIconButton> createState() => _ShadIconButtonState();
}

class _ShadIconButtonState extends State<ShadIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const radius = 12.0;

    // Cores base (variante outline): fundo da superfície + borda do input.
    final baseBg = isDark ? const Color(0xFF2A2E31) : Colors.white;
    final accent = colors.onSurface.withValues(alpha: isDark ? 0.10 : 0.06);

    final Color bg;
    final Color borderColor;
    final Color iconColor;
    if (widget.selected) {
      bg = colors.primary.withValues(alpha: isDark ? 0.22 : 0.12);
      borderColor = colors.primary.withValues(alpha: 0.55);
      iconColor = colors.primary;
    } else {
      bg = _hovered ? Color.alphaBlend(accent, baseBg) : baseBg;
      borderColor = colors.outline.withValues(alpha: isDark ? 0.4 : 0.25);
      iconColor = colors.onSurface;
    }

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
            boxShadow: widget.selected
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.06,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 20, color: iconColor),
        ),
      ),
    );

    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}
