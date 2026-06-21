import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/features/expenses/domain/expense.dart';
import 'package:spendly/features/expenses/domain/expense_calculator.dart';
import 'package:spendly/features/expenses/domain/payment_method.dart';

Expense _expense({
  required String categoryId,
  required String categoryName,
  required double amount,
  int color = 0xFF000000,
}) {
  final now = DateTime(2026, 6, 17);
  return Expense(
    id: 'id_$categoryId$amount',
    userId: 'u1',
    amount: amount,
    description: 'teste',
    categoryId: categoryId,
    categoryName: categoryName,
    categoryColor: color,
    paymentMethod: PaymentMethod.pix,
    date: now,
    note: '',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final sample = [
    _expense(categoryId: 'food', categoryName: 'Alimentação', amount: 100),
    _expense(categoryId: 'food', categoryName: 'Alimentação', amount: 50),
    _expense(categoryId: 'transport', categoryName: 'Transporte', amount: 50),
  ];

  group('ExpenseCalculator.total', () {
    test('soma todos os valores', () {
      expect(ExpenseCalculator.total(sample), 200);
    });

    test('lista vazia retorna 0', () {
      expect(ExpenseCalculator.total([]), 0);
    });
  });

  group('ExpenseCalculator.average', () {
    test('média correta', () {
      expect(ExpenseCalculator.average(sample), closeTo(66.666, 0.01));
    });

    test('lista vazia retorna 0', () {
      expect(ExpenseCalculator.average([]), 0);
    });
  });

  group('ExpenseCalculator.breakdownByCategory', () {
    final breakdown = ExpenseCalculator.breakdownByCategory(sample);

    test('agrupa por categoria', () {
      expect(breakdown.length, 2);
    });

    test('ordena do maior para o menor', () {
      expect(breakdown.first.categoryName, 'Alimentação');
      expect(breakdown.first.totalAmount, 150);
    });

    test('calcula percentual corretamente', () {
      expect(breakdown.first.percentage, 75); // 150 / 200
      expect(breakdown.last.percentage, 25); // 50 / 200
    });
  });

  group('ExpenseCalculator.summarize', () {
    final summary = ExpenseCalculator.summarize(sample);

    test('total e contagem', () {
      expect(summary.totalAmount, 200);
      expect(summary.expenseCount, 3);
    });

    test('maior categoria', () {
      expect(summary.highestCategoryName, 'Alimentação');
      expect(summary.highestCategoryAmount, 150);
    });

    test('lista vazia retorna summary vazio', () {
      final empty = ExpenseCalculator.summarize([]);
      expect(empty.isEmpty, isTrue);
      expect(empty.totalAmount, 0);
    });
  });
}
