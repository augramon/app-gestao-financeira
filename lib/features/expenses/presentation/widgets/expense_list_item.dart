import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_filter_utils.dart';
import '../../domain/expense.dart';
import '../../domain/payment_method.dart';

/// Item da lista de gastos: cor da categoria, descrição, categoria + forma
/// de pagamento, valor e data.
class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
    this.showDate = false,
  });

  final Expense expense;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = expense.categoryColorValue;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(expense.paymentMethod.icon, color: color, size: 20),
      ),
      title: Text(
        expense.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        showDate
            ? '${expense.categoryName} · ${DateFilterUtils.formatDate(expense.date)}'
            : '${expense.categoryName} · ${expense.paymentMethod.label}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.format(expense.amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (expense.isInstallment)
            Text(
              '${expense.installments}x de ${CurrencyFormatter.format(expense.installmentAmount)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
