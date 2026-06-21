import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test('rejeita vazio', () => expect(Validators.name(''), isNotNull));
    test('rejeita curto', () => expect(Validators.name('A'), isNotNull));
    test('aceita válido', () => expect(Validators.name('Ana'), isNull));
  });

  group('Validators.email', () {
    test('rejeita vazio', () => expect(Validators.email(''), isNotNull));
    test('rejeita inválido', () => expect(Validators.email('abc'), isNotNull));
    test(
      'rejeita sem domínio',
      () => expect(Validators.email('a@b'), isNotNull),
    );
    test(
      'aceita válido',
      () => expect(Validators.email('ana@email.com'), isNull),
    );
  });

  group('Validators.password', () {
    test('rejeita vazia', () => expect(Validators.password(''), isNotNull));
    test(
      'rejeita menor que 8',
      () => expect(Validators.password('1234567'), isNotNull),
    );
    test('aceita 8+', () => expect(Validators.password('12345678'), isNull));
  });

  group('Validators.confirmPassword', () {
    test(
      'rejeita diferente',
      () => expect(Validators.confirmPassword('abc', 'abd'), isNotNull),
    );
    test(
      'aceita igual',
      () => expect(Validators.confirmPassword('abc', 'abc'), isNull),
    );
  });

  group('Validators.amount', () {
    test('rejeita nulo', () => expect(Validators.amount(null), isNotNull));
    test('rejeita zero', () => expect(Validators.amount(0), isNotNull));
    test('rejeita negativo', () => expect(Validators.amount(-5), isNotNull));
    test('aceita positivo', () => expect(Validators.amount(10.5), isNull));
  });
}
