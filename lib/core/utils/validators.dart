/// Validações reutilizáveis para formulários.
///
/// Cada método retorna `null` quando válido ou uma mensagem de erro.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu nome.';
    if (text.length < 2) return 'Nome muito curto.';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu e-mail.';
    if (!_emailRegex.hasMatch(text)) return 'E-mail inválido.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Informe sua senha.';
    if (text.length < 8) return 'A senha deve ter ao menos 8 caracteres.';
    return null;
  }

  /// Validação leve usada na tela de login (não impõe tamanho mínimo,
  /// apenas presença, para não vazar regras de senha).
  static String? requiredPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Informe sua senha.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirme sua senha.';
    if (value != original) return 'As senhas não coincidem.';
    return null;
  }

  /// Valida um valor monetário já convertido em [double].
  static String? amount(double? value) {
    if (value == null) return 'Informe o valor.';
    if (value <= 0) return 'O valor deve ser maior que zero.';
    return null;
  }

  static String? requiredField(String? value, {String label = 'campo'}) {
    if ((value ?? '').trim().isEmpty) return 'Informe $label.';
    return null;
  }
}
