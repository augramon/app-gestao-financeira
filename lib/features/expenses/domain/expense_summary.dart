import 'package:flutter/material.dart';

/// Distribuição de gastos de uma categoria dentro de um período.
class CategoryBreakdown {
  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
  });

  final String categoryId;
  final String categoryName;
  final int categoryColor;
  final double totalAmount;

  /// Percentual de 0 a 100 em relação ao total do período.
  final double percentage;

  Color get colorValue => Color(categoryColor);
}

/// Resumo financeiro calculado para o período selecionado.
class ExpenseSummary {
  const ExpenseSummary({
    required this.totalAmount,
    required this.expenseCount,
    required this.highestCategoryName,
    required this.highestCategoryAmount,
    required this.averageExpense,
    required this.dailyAverage,
    required this.categoryBreakdown,
  });

  final double totalAmount;
  final int expenseCount;
  final String? highestCategoryName;
  final double highestCategoryAmount;
  final double averageExpense;

  /// Gasto médio por dia ao longo do período coberto pelos gastos.
  final double dailyAverage;
  final List<CategoryBreakdown> categoryBreakdown;

  bool get isEmpty => expenseCount == 0;

  static const empty = ExpenseSummary(
    totalAmount: 0,
    expenseCount: 0,
    highestCategoryName: null,
    highestCategoryAmount: 0,
    averageExpense: 0,
    dailyAverage: 0,
    categoryBreakdown: [],
  );
}
