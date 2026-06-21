import 'expense.dart';
import 'expense_summary.dart';

/// Cálculos centralizados de resumo de gastos.
///
/// Funções puras (sem dependência de UI ou Firebase) para facilitar testes
/// e evitar duplicação de lógica entre telas.
class ExpenseCalculator {
  ExpenseCalculator._();

  /// Total somado de uma lista de gastos.
  static double total(List<Expense> expenses) {
    var sum = 0.0;
    for (final e in expenses) {
      sum += e.amount;
    }
    return sum;
  }

  /// Média por gasto (0 quando a lista está vazia).
  static double average(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    return total(expenses) / expenses.length;
  }

  /// Soma por categoria, ordenada do maior para o menor.
  static List<CategoryBreakdown> breakdownByCategory(List<Expense> expenses) {
    if (expenses.isEmpty) return const [];

    final totals = <String, double>{};
    final names = <String, String>{};
    final colors = <String, int>{};

    for (final e in expenses) {
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.amount;
      names[e.categoryId] = e.categoryName;
      colors[e.categoryId] = e.categoryColor;
    }

    final grandTotal = total(expenses);
    final result = totals.entries.map((entry) {
      final amount = entry.value;
      return CategoryBreakdown(
        categoryId: entry.key,
        categoryName: names[entry.key] ?? '',
        categoryColor: colors[entry.key] ?? 0xFF64748B,
        totalAmount: amount,
        percentage: grandTotal == 0 ? 0 : (amount / grandTotal) * 100,
      );
    }).toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return result;
  }

  /// Monta o resumo completo do período.
  static ExpenseSummary summarize(List<Expense> expenses) {
    if (expenses.isEmpty) return ExpenseSummary.empty;

    final breakdown = breakdownByCategory(expenses);
    final highest = breakdown.isNotEmpty ? breakdown.first : null;

    return ExpenseSummary(
      totalAmount: total(expenses),
      expenseCount: expenses.length,
      highestCategoryName: highest?.categoryName,
      highestCategoryAmount: highest?.totalAmount ?? 0,
      averageExpense: average(expenses),
      categoryBreakdown: breakdown,
    );
  }
}
