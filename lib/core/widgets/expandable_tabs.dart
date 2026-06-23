import 'package:flutter/material.dart';

/// Item de um [ExpandableTabs].
class ExpandableTabItem {
  const ExpandableTabItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Barra de navegação no estilo "expandable tabs" do shadcn/ui:
/// um contêiner em pílula (`rounded-2xl border bg-background shadow-sm`) onde
/// cada aba exibe apenas o ícone e a aba ativa se expande com uma animação
/// elástica, revelando o rótulo (`bg-muted` + cor de destaque).
///
/// Diferente do componente original (que desmarca ao clicar fora), aqui a
/// seleção é controlada — sempre há uma aba ativa, refletindo a rota atual.
class ExpandableTabs extends StatefulWidget {
  const ExpandableTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<ExpandableTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<ExpandableTabs> createState() => _ExpandableTabsState();
}

class _ExpandableTabsState extends State<ExpandableTabs> {
  int? _hovered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Equivalentes shadcn: contêiner = bg-background + border + shadow-sm.
    final containerBg = isDark ? const Color(0xFF1E2123) : Colors.white;
    final borderColor = colors.outline.withValues(alpha: isDark ? 0.4 : 0.18);
    // bg-muted das abas (ativa / hover).
    final mutedBg = colors.onSurface.withValues(alpha: isDark ? 0.12 : 0.07);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.tabs.length; i++)
                    _TabButton(
                      tab: widget.tabs[i],
                      selected: i == widget.selectedIndex,
                      hovered: i == _hovered,
                      mutedBg: mutedBg,
                      activeColor: colors.primary,
                      inactiveColor: colors.onSurfaceVariant,
                      onTap: () => widget.onChanged(i),
                      onHover: (h) => setState(() => _hovered = h ? i : null),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.hovered,
    required this.mutedBg,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    required this.onHover,
  });

  final ExpandableTabItem tab;
  final bool selected;
  final bool hovered;
  final Color mutedBg;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 420);
    const curve = Curves.easeOutBack;

    final bg = selected
        ? mutedBg
        : (hovered ? mutedBg.withValues(alpha: mutedBg.a * 0.6) : null);
    final fg = selected ? activeColor : inactiveColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 20, color: fg),
              // Rótulo que "cresce" da esquerda para a direita ao selecionar.
              AnimatedSize(
                duration: duration,
                curve: curve,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
