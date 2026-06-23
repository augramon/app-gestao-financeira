/// Comparação do total gasto no mês atual com o do mês anterior.
class MonthComparison {
  const MonthComparison({
    required this.currentTotal,
    required this.previousTotal,
  });

  final double currentTotal;
  final double previousTotal;

  static const empty = MonthComparison(currentTotal: 0, previousTotal: 0);

  /// Existe base de comparação (houve gastos no mês passado).
  bool get hasBaseline => previousTotal > 0;

  /// Variação percentual vs mês passado. `null` quando não há base.
  ///
  /// Positivo = gastou mais; negativo = gastou menos.
  double? get deltaPercent => hasBaseline
      ? (currentTotal - previousTotal) / previousTotal * 100
      : null;
}
