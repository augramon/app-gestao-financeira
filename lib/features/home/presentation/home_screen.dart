import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/summary_card.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/domain/expense_summary.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../expenses/presentation/widgets/expense_list_item.dart';
import '../../expenses/presentation/widgets/period_selector.dart';
import 'widgets/category_pie_chart.dart';

/// Dashboard inicial: saudação, período, total, resumo, gráfico e recentes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(appUserProvider).value;
    final greetingName = user?.firstName ?? '';
    final expensesAsync = ref.watch(expensesProvider);
    final summary = ref.watch(summaryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.expensesNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(expensesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingLg,
              AppConstants.spacingLg,
              96,
            ),
            children: [
              Text(
                'Olá${greetingName.isNotEmpty ? ', $greetingName' : ''} 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aqui está o resumo dos seus gastos.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              const PeriodSelector(),
              const SizedBox(height: AppConstants.spacingMd),
              _TotalCard(total: summary.totalAmount),
              const SizedBox(height: AppConstants.spacingMd),
              expensesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: AppLoading(),
                ),
                error: (_, _) => AppError(
                  message: 'Não foi possível carregar seus gastos.',
                  onRetry: () => ref.invalidate(expensesProvider),
                ),
                data: (expenses) => _DashboardContent(
                  summary: summary,
                  recent: expenses.take(5).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total gasto no período',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              CurrencyFormatter.format(total),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary, required this.recent});

  final ExpenseSummary summary;
  final List<Expense> recent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (summary.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: EmptyState(
          icon: Icons.insights_rounded,
          title: 'Sem gastos no período',
          message: 'Adicione um gasto para ver seu resumo e o gráfico.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Maior categoria',
                value: summary.highestCategoryName ?? '—',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: SummaryCard(
                label: 'Qtd. de gastos',
                value: '${summary.expenseCount}',
                icon: Icons.tag_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Média por gasto',
                value: CurrencyFormatter.format(summary.averageExpense),
                icon: Icons.calculate_rounded,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: SummaryCard(
                label: 'Maior valor',
                value: CurrencyFormatter.format(summary.highestCategoryAmount),
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Text(
          'Gastos por categoria',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: CategoryPieChart(breakdown: summary.categoryBreakdown),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gastos recentes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        ...recent.map(
          (e) => ExpenseListItem(
            expense: e,
            showDate: true,
            onTap: () => context.push(AppRoutes.expenseEdit(e.id), extra: e),
          ),
        ),
      ],
    );
  }
}
