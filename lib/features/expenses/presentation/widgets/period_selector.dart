import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_filter_utils.dart';
import '../expense_providers.dart';

/// Seletor de período: Hoje, Semana, Mês e intervalo personalizado.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  Future<void> _pickCustom(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      ref
          .read(dateFilterProvider.notifier)
          .setCustomRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dateFilterProvider);
    final controller = ref.read(dateFilterProvider.notifier);
    final isCustom = state.filter == DateFilter.custom;

    return Row(
      children: [
        Expanded(
          child: SegmentedButton<DateFilter>(
            segments: const [
              ButtonSegment(value: DateFilter.today, label: Text('Hoje')),
              ButtonSegment(value: DateFilter.week, label: Text('Semana')),
              ButtonSegment(value: DateFilter.month, label: Text('Mês')),
            ],
            selected: {isCustom ? DateFilter.month : state.filter},
            showSelectedIcon: false,
            onSelectionChanged: (s) => controller.setFilter(s.first),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Período personalizado',
          isSelected: isCustom,
          icon: const Icon(Icons.date_range_rounded),
          onPressed: () => _pickCustom(context, ref),
        ),
      ],
    );
  }
}
