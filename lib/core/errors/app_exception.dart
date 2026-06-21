/// Exceção de domínio com mensagem amigável ao usuário.
///
/// Nunca exponha mensagens técnicas do Firebase diretamente na UI.
/// Use [AppException] para traduzir erros em algo compreensível.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  /// Mensagem amigável, pronta para exibição.
  final String message;

  /// Código original (opcional) para depuração/log.
  final String? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Traduz códigos de erro do Firebase Authentication em mensagens amigáveis.
class AuthErrorMapper {
  AuthErrorMapper._();

  static AppException map(String? code) {
    switch (code) {
      case 'invalid-email':
        return const AppException('E-mail inválido.', code: 'invalid-email');
      case 'user-disabled':
        return const AppException(
          'Esta conta foi desativada.',
          code: 'user-disabled',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AppException(
          'E-mail ou senha incorretos.',
          code: 'invalid-credential',
        );
      case 'email-already-in-use':
        return const AppException(
          'Este e-mail já está em uso.',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AppException(
          'A senha é muito fraca. Use ao menos 8 caracteres.',
          code: 'weak-password',
        );
      case 'too-many-requests':
        return const AppException(
          'Muitas tentativas. Tente novamente em instantes.',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const AppException(
          'Sem conexão. Verifique sua internet.',
          code: 'network-request-failed',
        );
      case 'requires-recent-login':
        return const AppException(
          'Por segurança, entre novamente para concluir esta ação.',
          code: 'requires-recent-login',
        );
      default:
        return const AppException(
          'Algo deu errado. Tente novamente.',
          code: 'unknown',
        );
    }
  }
}
