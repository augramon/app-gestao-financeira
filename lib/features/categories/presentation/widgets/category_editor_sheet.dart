import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/expense_category.dart';

/// Resultado da edição: nome e cor (ARGB) escolhidos.
typedef CategoryEditorResult = ({String name, int color});

/// Abre o editor de categoria. Retorna `null` se cancelado.
Future<CategoryEditorResult?> showCategoryEditor(
  BuildContext context, {
  ExpenseCategory? initial,
}) {
  return showModalBottomSheet<CategoryEditorResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _CategoryEditor(initial: initial),
    ),
  );
}

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({this.initial});
  final ExpenseCategory? initial;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late int _color;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _color =
        widget.initial?.color ?? AppColors.categoryPalette.first.toARGB32();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((name: _name.text.trim(), color: _color));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initial != null;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Editar categoria' : 'Nova categoria',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (v) => Validators.requiredField(v, label: 'um nome'),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              'Cor',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColors.categoryPalette.map((color) {
                final argb = color.toARGB32();
                final selected = argb == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = argb),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            PrimaryButton(
              label: isEditing ? 'Salvar' : 'Criar categoria',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
