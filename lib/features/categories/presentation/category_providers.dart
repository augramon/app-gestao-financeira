import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../domain/expense_category.dart';

/// Categorias do usuário, observadas em tempo real.
final categoriesProvider = StreamProvider.autoDispose<List<ExpenseCategory>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(categoryRepositoryProvider).watchCategories(uid);
});

/// Controla a criação, edição e exclusão de categorias personalizadas.
class CategoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> create({required String name, required int color}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUidProvider);
      if (uid == null) throw const AppException('Sessão expirada.');
      final repo = ref.read(categoryRepositoryProvider);
      final now = DateTime.now();
      final category = ExpenseCategory(
        id: repo.newId(uid),
        userId: uid,
        name: name.trim(),
        color: color,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );
      await repo.addCategory(category);
    });
    return !state.hasError;
  }

  Future<bool> edit(
    ExpenseCategory category, {
    required String name,
    required int color,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.updateCategory(
        category.copyWith(name: name, color: color, updatedAt: DateTime.now()),
      );
    });
    return !state.hasError;
  }

  Future<bool> delete(ExpenseCategory category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (category.isDefault) {
        throw const AppException('Categorias padrão não podem ser excluídas.');
      }
      await ref
          .read(categoryRepositoryProvider)
          .deleteCategory(category.userId, category.id);
    });
    return !state.hasError;
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider.autoDispose<CategoryController, void>(
      CategoryController.new,
    );
