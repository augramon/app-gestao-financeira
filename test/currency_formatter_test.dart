import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/utils/currency_formatter.dart';

void main() {
  // Normaliza espacos nao separaveis (U+00A0 e U+202F) usados pelo intl.
  String norm(String s) => s
      .replaceAll(String.fromCharCode(0x00A0), ' ')
      .replaceAll(String.fromCharCode(0x202F), ' ');

  group('CurrencyFormatter.format', () {
    test('formata em reais com simbolo e 2 casas decimais', () {
      final out = norm(CurrencyFormatter.format(120.5));
      expect(out, contains('R\$'));
      expect(out, contains('120,50'));
    });

    test('formata milhares com separador de ponto', () {
      expect(norm(CurrencyFormatter.format(1248.9)), contains('1.248,90'));
    });

    test('formata zero', () {
      expect(norm(CurrencyFormatter.format(0)), contains('0,00'));
    });
  });

  group('CurrencyFormatter.tryParse', () {
    test('parseia formato BR com milhar e decimal', () {
      expect(CurrencyFormatter.tryParse('1.248,90'), 1248.90);
    });

    test('parseia valor simples com virgula', () {
      expect(CurrencyFormatter.tryParse('120,50'), 120.50);
    });

    test('parseia valor com ponto decimal', () {
      expect(CurrencyFormatter.tryParse('120.50'), 120.50);
    });

    test('ignora simbolo de moeda', () {
      expect(CurrencyFormatter.tryParse('R\$ 50,00'), 50.0);
    });

    test('retorna nulo para texto vazio', () {
      expect(CurrencyFormatter.tryParse(''), isNull);
    });

    test('retorna nulo para texto invalido', () {
      expect(CurrencyFormatter.tryParse('abc'), isNull);
    });
  });
}
