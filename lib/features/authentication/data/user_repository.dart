import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../categories/domain/expense_category.dart';
import '../domain/app_user.dart';

/// Acesso ao perfil do usuário e às suas categorias no Firestore.
class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(FirestoreConstants.usersCollection).doc(uid);

  /// Cria o documento do usuário e semeia as categorias padrão num único batch.
  ///
  /// A senha nunca é gravada — apenas nome, e-mail e timestamps.
  Future<AppUser> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final now = DateTime.now();
    final user = AppUser(
      id: uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final batch = _db.batch();
    batch.set(_userDoc(uid), user.toMap());

    final categoriesRef = _userDoc(
      uid,
    ).collection(FirestoreConstants.categoriesCollection);
    for (final item in DefaultCategories.items) {
      final id = _uuid.v4();
      final category = ExpenseCategory(
        id: id,
        userId: uid,
        name: item.name,
        color: item.color.toARGB32(),
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(categoriesRef.doc(id), category.toMap());
    }

    await batch.commit();
    return user;
  }

  Future<AppUser?> fetchUser(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return AppUser.fromMap(uid, data);
  }

  /// Stream do perfil para refletir alterações em tempo real.
  Stream<AppUser?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromMap(uid, data);
    });
  }

  Future<void> updateName(String uid, String name) {
    return _userDoc(uid).update({
      FirestoreConstants.fieldName: name.trim(),
      FirestoreConstants.fieldUpdatedAt: Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteUserData(String uid) async {
    // Remove subcoleções e o documento do usuário.
    final categories = await _userDoc(
      uid,
    ).collection(FirestoreConstants.categoriesCollection).get();
    final expenses = await _userDoc(
      uid,
    ).collection(FirestoreConstants.expensesCollection).get();
    final batch = _db.batch();
    for (final doc in categories.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in expenses.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_userDoc(uid));
    await batch.commit();
  }
}
