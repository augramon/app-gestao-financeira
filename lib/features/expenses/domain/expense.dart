import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/firestore_constants.dart';
import 'payment_method.dart';

/// Um gasto registrado pelo usuário.
///
/// Os campos da categoria são denormalizados (nome e cor) para permitir
/// exibir listas e gráficos sem cruzar dados com a coleção de categorias.
class Expense {
  const Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.paymentMethod,
    required this.date,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.installments = 1,
  });

  final String id;
  final String userId;
  final double amount;
  final String description;
  final String categoryId;
  final String categoryName;
  final int categoryColor;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Número de parcelas. 1 = à vista (não parcelado).
  final int installments;

  Color get categoryColorValue => Color(categoryColor);

  /// Verdadeiro quando a compra foi parcelada (mais de uma parcela).
  bool get isInstallment => installments > 1;

  /// Valor de cada parcela ([amount] é o valor total da compra).
  double get installmentAmount =>
      installments > 0 ? amount / installments : amount;

  Expense copyWith({
    double? amount,
    String? description,
    String? categoryId,
    String? categoryName,
    int? categoryColor,
    PaymentMethod? paymentMethod,
    DateTime? date,
    String? note,
    DateTime? updatedAt,
    int? installments,
  }) {
    return Expense(
      id: id,
      userId: userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      installments: installments ?? this.installments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.fieldAmount: amount,
      FirestoreConstants.fieldDescription: description,
      FirestoreConstants.fieldCategoryId: categoryId,
      FirestoreConstants.fieldCategoryName: categoryName,
      FirestoreConstants.fieldCategoryColor: categoryColor,
      FirestoreConstants.fieldPaymentMethod: paymentMethod.name,
      FirestoreConstants.fieldInstallments: installments,
      FirestoreConstants.fieldDate: Timestamp.fromDate(date),
      FirestoreConstants.fieldNote: note,
      FirestoreConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      FirestoreConstants.fieldUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  factory Expense.fromMap(String id, String userId, Map<String, dynamic> map) {
    return Expense(
      id: id,
      userId: userId,
      amount: (map[FirestoreConstants.fieldAmount] as num?)?.toDouble() ?? 0,
      description: (map[FirestoreConstants.fieldDescription] ?? '') as String,
      categoryId: (map[FirestoreConstants.fieldCategoryId] ?? '') as String,
      categoryName: (map[FirestoreConstants.fieldCategoryName] ?? '') as String,
      categoryColor:
          (map[FirestoreConstants.fieldCategoryColor] as num?)?.toInt() ??
          0xFF64748B,
      paymentMethod: PaymentMethodInfo.fromName(
        map[FirestoreConstants.fieldPaymentMethod] as String?,
      ),
      installments:
          (map[FirestoreConstants.fieldInstallments] as num?)?.toInt() ?? 1,
      date: _toDate(map[FirestoreConstants.fieldDate]),
      note: (map[FirestoreConstants.fieldNote] ?? '') as String,
      createdAt: _toDate(map[FirestoreConstants.fieldCreatedAt]),
      updatedAt: _toDate(map[FirestoreConstants.fieldUpdatedAt]),
    );
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
