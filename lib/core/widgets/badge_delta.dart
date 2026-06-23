import 'package:flutter/material.dart';

/// Direção da variação (define a seta exibida).
enum BadgeDeltaType { increase, decrease, neutral }

/// Estilo visual do badge.
enum BadgeDeltaVariant { outline, solid }

/// Badge de variação percentual com seta colorida — réplica em Flutter do
/// componente shadcn/Tremor `badge-delta`.
///
/// A seta segue [deltaType]; a cor (verde/vermelho) é resolvida por [tone],
/// que considera [higherIsBetter] — para gastos, mais alto é pior, então
/// passa-se `higherIsBetter: false` (subida fica vermelha).
class BadgeDelta extends StatelessWidget {
  const BadgeDelta({
    super.key,
    required this.value,
    this.deltaType = BadgeDeltaType.neutral,
    this.variant = BadgeDeltaVariant.outline,
    this.higherIsBetter = true,
  });

  final String value;
  final BadgeDeltaType deltaType;
  final BadgeDeltaVariant variant;
  final bool higherIsBetter;

  bool get _isGood => switch (deltaType) {
    BadgeDeltaType.increase => higherIsBetter,
    BadgeDeltaType.decrease => !higherIsBetter,
    BadgeDeltaType.neutral => false,
  };

  IconData get _icon => switch (deltaType) {
    BadgeDeltaType.increase => Icons.arrow_drop_up,
    BadgeDeltaType.decrease => Icons.arrow_drop_down,
    BadgeDeltaType.neutral => Icons.arrow_right,
  };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (fg, bg) = _colors(dark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: variant == BadgeDeltaVariant.solid ? bg : null,
        borderRadius: BorderRadius.circular(6),
        border: variant == BadgeDeltaVariant.outline
            ? Border.all(color: fg.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 18, color: fg),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna (cor do conteúdo, cor de fundo do estilo solid).
  (Color, Color) _colors(bool dark) {
    if (deltaType == BadgeDeltaType.neutral) {
      final fg = dark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
      final bg = dark ? const Color(0x4D6B7280) : const Color(0x80E5E7EB);
      return (fg, bg);
    }
    if (_isGood) {
      // Verde (emerald).
      final fg = dark ? const Color(0xFF34D399) : const Color(0xFF047857);
      final bg = dark ? const Color(0x3334D399) : const Color(0xFFD1FAE5);
      return (fg, bg);
    }
    // Vermelho (red).
    final fg = dark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
    final bg = dark ? const Color(0x33F87171) : const Color(0xFFFEE2E2);
    return (fg, bg);
  }
}
