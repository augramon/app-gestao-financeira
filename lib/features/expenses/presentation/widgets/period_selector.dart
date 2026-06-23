import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_filter_utils.dart';
import '../../../../core/widgets/segmented_toggle.dart';
import '../../../../core/widgets/shad_icon_button.dart';
import '../expense_providers.dart';

/// Seletor de período: Hoje, Semana, Mês e intervalo personalizado.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  Future<void> _pickCustom(
    BuildContext context,
    WidgetRef ref,
    DateFilterState state,
  ) async {
    final now = DateTime.now();
    final initial = state.filter == DateFilter.custom
        ? (state.customStart ?? now)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'Filtrar',
    );
    if (picked != null) {
      // Filtra exatamente o dia escolhido (início/fim do mesmo dia).
      ref.read(dateFilterProvider.notifier).setCustomRange(picked, picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dateFilterProvider);
    final controller = ref.read(dateFilterProvider.notifier);
    final isCustom = state.filter == DateFilter.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedToggle<DateFilter>(
                segments: const [
                  SegmentItem(value: DateFilter.today, label: 'Hoje'),
                  SegmentItem(value: DateFilter.week, label: 'Semana'),
                  SegmentItem(value: DateFilter.month, label: 'Mês'),
                ],
                // Sem seleção quando um intervalo personalizado está ativo.
                value: isCustom ? null : state.filter,
                onChanged: controller.setFilter,
              ),
            ),
            const SizedBox(width: 8),
            ShadIconButton(
              tooltip: 'Filtrar por data',
              icon: Icons.event_rounded,
              selected: isCustom,
              onPressed: () => _pickCustom(context, ref, state),
            ),
          ],
        ),
        if (isCustom && state.customStart != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: InputChip(
              avatar: const Icon(Icons.event_rounded, size: 18),
              label: Text(DateFilterUtils.formatDate(state.customStart!)),
              onPressed: () => _pickCustom(context, ref, state),
              onDeleted: () => controller.setFilter(DateFilter.month),
              deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
