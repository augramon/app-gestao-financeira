/// Nomes de coleções e campos do Firestore centralizados.
///
/// Mantém a estrutura consistente entre repositórios e regras de segurança.
class FirestoreConstants {
  FirestoreConstants._();

  // Coleções.
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String categoriesCollection = 'categories';

  // Campos comuns.
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // Campos de gasto.
  static const String fieldAmount = 'amount';
  static const String fieldDescription = 'description';
  static const String fieldCategoryId = 'categoryId';
  static const String fieldCategoryName = 'categoryName';
  static const String fieldCategoryColor = 'categoryColor';
  static const String fieldPaymentMethod = 'paymentMethod';
  static const String fieldDate = 'date';
  static const String fieldNote = 'note';

  // Campos de categoria.
  static const String fieldColor = 'color';
  static const String fieldIsDefault = 'isDefault';
}
