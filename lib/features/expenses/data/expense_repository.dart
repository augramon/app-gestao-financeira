import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../domain/expense.dart';

/// Acesso aos gastos do usuário no Firestore.
class ExpenseRepository {
  ExpenseRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _db
      .collection(FirestoreConstants.usersCollection)
      .doc(uid)
      .collection(FirestoreConstants.expensesCollection);

  /// Observa os gastos dentro do intervalo, do mais recente para o mais antigo.
  Stream<List<Expense>> watchExpenses(String uid, DateRange range) {
    return _col(uid)
        .where(
          FirestoreConstants.fieldDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(range.start),
          isLessThan: Timestamp.fromDate(range.end),
        )
        .orderBy(FirestoreConstants.fieldDate, descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Expense.fromMap(d.id, uid, d.data()))
              .toList(),
        );
  }

  /// Observa todos os gastos do usuário (sem filtro de período), do mais
  /// recente para o mais antigo.
  Stream<List<Expense>> watchAll(String uid) {
    return _col(uid)
        .orderBy(FirestoreConstants.fieldDate, descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Expense.fromMap(d.id, uid, d.data()))
              .toList(),
        );
  }

  /// Conta todos os gastos do usuário (sem filtro de período).
  Future<int> countAll(String uid) async {
    final snap = await _col(uid).count().get();
    return snap.count ?? 0;
  }

  Future<void> addExpense(Expense expense) {
    return _col(expense.userId).doc(expense.id).set(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) {
    return _col(expense.userId).doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String uid, String expenseId) {
    return _col(uid).doc(expenseId).delete();
  }

  /// Gera um novo id de documento.
  String newId(String uid) => _col(uid).doc().id;
}
