import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/expense_category.dart';
import 'category_providers.dart';
import 'widgets/category_editor_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showCategoryEditor(context);
    if (result == null) return;
    final ok = await ref
        .read(categoryControllerProvider.notifier)
        .create(name: result.name, color: result.color);
    if (context.mounted) {
      _showMessage(
        context,
        ok ? 'Categoria criada.' : 'Não foi possível criar.',
      );
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    ExpenseCategory category,
  ) async {
    final result = await showCategoryEditor(context, initial: category);
    if (result == null) return;
    final ok = await ref
        .read(categoryControllerProvider.notifier)
        .edit(category, name: result.name, color: result.color);
    if (context.mounted) {
      _showMessage(
        context,
        ok ? 'Categoria atualizada.' : 'Não foi possível atualizar.',
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ExpenseCategory category,
  ) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Excluir categoria',
      message:
          'Excluir "${category.name}"? Gastos já registrados não serão alterados.',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );
    if (!confirm) return;
    final ok = await ref
        .read(categoryControllerProvider.notifier)
        .delete(category);
    if (context.mounted) {
      final error = ref.read(categoryControllerProvider).error;
      _showMessage(
        context,
        ok
            ? 'Categoria excluída.'
            : (error is AppException
                  ? error.message
                  : 'Não foi possível excluir.'),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova categoria'),
      ),
      body: categoriesAsync.when(
        loading: () => const AppLoading(),
        error: (_, _) => AppError(
          message: 'Não foi possível carregar as categorias.',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Nenhuma categoria.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              AppConstants.spacingSm,
              AppConstants.spacingMd,
              96,
            ),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final category = categories[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.colorValue.withValues(alpha: 0.18),
                  child: Icon(
                    Icons.label_rounded,
                    color: category.colorValue,
                    size: 20,
                  ),
                ),
                title: Text(category.name),
                subtitle: Text(category.isDefault ? 'Padrão' : 'Personalizada'),
                trailing: category.isDefault
                    ? null
                    : PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _edit(context, ref, category);
                          if (value == 'delete') {
                            _delete(context, ref, category);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Excluir'),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
