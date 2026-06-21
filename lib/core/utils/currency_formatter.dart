import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formatação e parsing de valores monetários em Real (BRL).
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
  );

  /// Ex.: 120.5 -> "R$ 120,50".
  static String format(num value) => _currency.format(value);

  /// Versão compacta para números grandes. Ex.: 1248.9 -> "R$ 1,25 mil".
  static String compact(num value) => _compact.format(value);

  /// Converte texto digitado (ex.: "1.248,90") em [double].
  ///
  /// Aceita separador de milhar com ponto e decimal com vírgula (padrão BR),
  /// e também o formato simples com ponto decimal.
  static double? tryParse(String? input) {
    if (input == null) return null;
    var text = input.trim();
    if (text.isEmpty) return null;

    // Remove símbolo e espaços.
    text = text.replaceAll(AppConstants.currencySymbol, '').trim();

    final hasComma = text.contains(',');
    if (hasComma) {
      // Formato BR: ponto = milhar, vírgula = decimal.
      text = text.replaceAll('.', '').replaceAll(',', '.');
    }
    // Mantém apenas dígitos, ponto e sinal.
    text = text.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(text);
  }
}
