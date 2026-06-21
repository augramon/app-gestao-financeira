import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/expense.dart';
import 'expense_providers.dart';
import 'widgets/expense_list_item.dart';
import 'widgets/period_selector.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _query = '';

  /// Agrupa por dia preservando a ordem decrescente já vinda da query.
  Map<String, List<Expense>> _groupByDay(List<Expense> expenses) {
    final groups = <String, List<Expense>>{};
    for (final e in expenses) {
      final label = DateFilterUtils.relativeLabel(e.date);
      groups.putIfAbsent(label, () => []).add(e);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.expensesNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo gasto'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              AppConstants.spacingSm,
              AppConstants.spacingMd,
              AppConstants.spacingSm,
            ),
            child: Column(
              children: [
                const PeriodSelector(),
                const SizedBox(height: AppConstants.spacingSm),
                TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por descrição',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              loading: () => const AppLoading(),
              error: (_, _) => AppError(
                message: 'Não foi possível carregar os gastos.',
                onRetry: () => ref.invalidate(expensesProvider),
              ),
              data: (all) {
                final expenses = _query.isEmpty
                    ? all
                    : all
                          .where(
                            (e) => e.description.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                          )
                          .toList();

                if (expenses.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: _query.isEmpty
                        ? 'Nenhum gasto no período'
                        : 'Nada encontrado',
                    message: _query.isEmpty
                        ? 'Toque em "Novo gasto" para registrar sua primeira despesa.'
                        : 'Tente outra descrição.',
                  );
                }

                final groups = _groupByDay(expenses);
                final total = expenses.fold<double>(
                  0,
                  (sum, e) => sum + e.amount,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacingMd,
                    0,
                    AppConstants.spacingMd,
                    96,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${expenses.length} gasto(s) · ${CurrencyFormatter.format(total)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    for (final entry in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          entry.key,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (e) => ExpenseListItem(
                          expense: e,
                          onTap: () => context.push(
                            AppRoutes.expenseEdit(e.id),
                            extra: e,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
