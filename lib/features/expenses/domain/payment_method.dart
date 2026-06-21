import 'package:flutter/material.dart';

/// Formas de pagamento suportadas pelo MVP.
enum PaymentMethod {
  cash,
  pix,
  debitCard,
  creditCard,
  bankSlip,
  bankTransfer,
  other,
}

extension PaymentMethodInfo on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.debitCard:
        return 'Cartão de débito';
      case PaymentMethod.creditCard:
        return 'Cartão de crédito';
      case PaymentMethod.bankSlip:
        return 'Boleto';
      case PaymentMethod.bankTransfer:
        return 'Transferência';
      case PaymentMethod.other:
        return 'Outro';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.pix:
        return Icons.pix_rounded;
      case PaymentMethod.debitCard:
        return Icons.credit_card_outlined;
      case PaymentMethod.creditCard:
        return Icons.credit_card_rounded;
      case PaymentMethod.bankSlip:
        return Icons.receipt_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.swap_horiz_rounded;
      case PaymentMethod.other:
        return Icons.more_horiz_rounded;
    }
  }

  /// Converte o nome armazenado de volta para o enum (com fallback seguro).
  static PaymentMethod fromName(String? name) {
    return PaymentMethod.values.firstWhere(
      (m) => m.name == name,
      orElse: () => PaymentMethod.other,
    );
  }
}
