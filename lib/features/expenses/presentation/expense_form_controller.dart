import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../categories/domain/expense_category.dart';
import '../domain/expense.dart';
import '../domain/payment_method.dart';

/// Controla a criação, edição e exclusão de gastos.
class ExpenseFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save({
    String? id,
    required double amount,
    required String description,
    required ExpenseCategory category,
    required PaymentMethod paymentMethod,
    required DateTime date,
    required String note,
    DateTime? createdAt,
    int installments = 1,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUidProvider);
      if (uid == null) throw const AppException('Sessão expirada.');

      final repo = ref.read(expenseRepositoryProvider);
      final now = DateTime.now();
      final isNew = id == null;
      final expense = Expense(
        id: id ?? repo.newId(uid),
        userId: uid,
        amount: amount,
        description: description.trim(),
        categoryId: category.id,
        categoryName: category.name,
        categoryColor: category.color,
        paymentMethod: paymentMethod,
        date: date,
        note: note.trim(),
        createdAt: createdAt ?? now,
        updatedAt: now,
        installments: installments,
      );

      if (isNew) {
        await repo.addExpense(expense);
      } else {
        await repo.updateExpense(expense);
      }
    });
    return !state.hasError;
  }

  Future<bool> delete(String expenseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUidProvider);
      if (uid == null) throw const AppException('Sessão expirada.');
      await ref.read(expenseRepositoryProvider).deleteExpense(uid, expenseId);
    });
    return !state.hasError;
  }
}

final expenseFormControllerProvider =
    AsyncNotifierProvider.autoDispose<ExpenseFormController, void>(
      ExpenseFormController.new,
    );
