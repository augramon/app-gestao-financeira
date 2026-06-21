import 'package:flutter/material.dart';

import '../../domain/expense_category.dart';

/// Seletor de categoria em formato de chips, com cor de cada categoria.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ExpenseCategory> categories;
  final String? selectedId;
  final ValueChanged<ExpenseCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final selected = category.id == selectedId;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onSelected(category),
          avatar: CircleAvatar(backgroundColor: category.colorValue, radius: 7),
          label: Text(category.name),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
