import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';

/// Perfil do usuário armazenado no Firestore.
///
/// A senha NUNCA é persistida aqui — autenticação é responsabilidade
/// exclusiva do Firebase Authentication.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Primeiro nome, usado em saudações.
  String get firstName => name.trim().split(' ').first;

  AppUser copyWith({String? name, DateTime? updatedAt}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.fieldName: name,
      FirestoreConstants.fieldEmail: email,
      FirestoreConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      FirestoreConstants.fieldUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: (map[FirestoreConstants.fieldName] ?? '') as String,
      email: (map[FirestoreConstants.fieldEmail] ?? '') as String,
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
