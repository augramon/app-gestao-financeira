import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../domain/expense_category.dart';

/// Acesso às categorias do usuário no Firestore.
class CategoryRepository {
  CategoryRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _db
      .collection(FirestoreConstants.usersCollection)
      .doc(uid)
      .collection(FirestoreConstants.categoriesCollection);

  /// Observa as categorias, ordenadas por nome.
  Stream<List<ExpenseCategory>> watchCategories(String uid) {
    return _col(uid)
        .orderBy(FirestoreConstants.fieldName)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ExpenseCategory.fromMap(d.id, uid, d.data()))
              .toList(),
        );
  }

  Future<void> addCategory(ExpenseCategory category) {
    return _col(category.userId).doc(category.id).set(category.toMap());
  }

  Future<void> updateCategory(ExpenseCategory category) {
    return _col(category.userId).doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String uid, String categoryId) {
    return _col(uid).doc(categoryId).delete();
  }

  String newId(String uid) => _col(uid).doc().id;
}
