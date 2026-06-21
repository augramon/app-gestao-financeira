import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../domain/expense.dart';
import '../domain/expense_calculator.dart';
import '../domain/expense_summary.dart';

/// Estado do filtro de período selecionado.
class DateFilterState {
  const DateFilterState({
    this.filter = DateFilter.month,
    this.customStart,
    this.customEnd,
  });

  final DateFilter filter;
  final DateTime? customStart;
  final DateTime? customEnd;

  DateRange get range => DateFilterUtils.rangeFor(
    filter,
    customStart: customStart,
    customEnd: customEnd,
  );

  DateFilterState copyWith({
    DateFilter? filter,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return DateFilterState(
      filter: filter ?? this.filter,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }
}

/// Controla o período usado em toda a aplicação (home e lista de gastos).
class DateFilterController extends Notifier<DateFilterState> {
  @override
  DateFilterState build() => const DateFilterState();

  void setFilter(DateFilter filter) {
    state = DateFilterState(filter: filter);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = DateFilterState(
      filter: DateFilter.custom,
      customStart: start,
      customEnd: end,
    );
  }
}

final dateFilterProvider =
    NotifierProvider<DateFilterController, DateFilterState>(
      DateFilterController.new,
    );

/// Gastos do período selecionado, observados em tempo real.
final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  final filterState = ref.watch(dateFilterProvider);
  return ref
      .watch(expenseRepositoryProvider)
      .watchExpenses(uid, filterState.range);
});

/// Resumo derivado dos gastos do período.
final summaryProvider = Provider.autoDispose<ExpenseSummary>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const [];
  return ExpenseCalculator.summarize(expenses);
});

/// Total de gastos cadastrados pelo usuário (todos os períodos).
final totalExpenseCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return 0;
  return ref.watch(expenseRepositoryProvider).countAll(uid);
});
