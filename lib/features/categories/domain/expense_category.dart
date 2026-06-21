import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firestore_constants.dart';

/// Categoria de gasto (padrão ou personalizada pelo usuário).
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;

  /// Cor armazenada como inteiro ARGB.
  final int color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Color get colorValue => Color(color);

  ExpenseCategory copyWith({String? name, int? color, DateTime? updatedAt}) {
    return ExpenseCategory(
      id: id,
      userId: userId,
      name: name ?? this.name,
      color: color ?? this.color,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.fieldName: name,
      FirestoreConstants.fieldColor: color,
      FirestoreConstants.fieldIsDefault: isDefault,
      FirestoreConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      FirestoreConstants.fieldUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  factory ExpenseCategory.fromMap(
    String id,
    String userId,
    Map<String, dynamic> map,
  ) {
    return ExpenseCategory(
      id: id,
      userId: userId,
      name: (map[FirestoreConstants.fieldName] ?? '') as String,
      color:
          (map[FirestoreConstants.fieldColor] ?? AppColors.seed.toARGB32())
              as int,
      isDefault: (map[FirestoreConstants.fieldIsDefault] ?? false) as bool,
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

/// Definição das categorias padrão criadas para cada novo usuário.
class DefaultCategories {
  DefaultCategories._();

  /// Nome + cor sugerida (índice da paleta).
  static const List<({String name, Color color})> items = [
    (name: 'Alimentação', color: Color(0xFF1B8A5A)),
    (name: 'Transporte', color: Color(0xFF2563EB)),
    (name: 'Moradia', color: Color(0xFFF59E0B)),
    (name: 'Saúde', color: Color(0xFFEC4899)),
    (name: 'Educação', color: Color(0xFF8B5CF6)),
    (name: 'Lazer', color: Color(0xFF0EA5E9)),
    (name: 'Compras', color: Color(0xFF14B8A6)),
    (name: 'Assinaturas', color: Color(0xFF6366F1)),
    (name: 'Contas', color: Color(0xFFEF4444)),
    (name: 'Outros', color: Color(0xFF64748B)),
  ];
}
