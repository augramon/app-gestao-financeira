import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/utils/date_filter_utils.dart';

void main() {
  group('DateFilterUtils.rangeFor - hoje', () {
    final ref = DateTime(2026, 6, 17, 14, 30);
    final range = DateFilterUtils.rangeFor(DateFilter.today, reference: ref);

    test('inicia à meia-noite do dia', () {
      expect(range.start, DateTime(2026, 6, 17));
    });

    test('dura exatamente um dia', () {
      expect(range.end.difference(range.start).inDays, 1);
    });

    test('contém o momento de referência', () {
      expect(range.contains(ref), isTrue);
    });

    test('não contém o dia anterior', () {
      expect(range.contains(DateTime(2026, 6, 16, 23, 59)), isFalse);
    });
  });

  group('DateFilterUtils.rangeFor - semana', () {
    // 2026-06-17 é uma quarta-feira.
    final ref = DateTime(2026, 6, 17, 10);
    final range = DateFilterUtils.rangeFor(DateFilter.week, reference: ref);

    test('começa na segunda-feira', () {
      expect(range.start.weekday, DateTime.monday);
      expect(range.start, DateTime(2026, 6, 15));
    });

    test('dura sete dias', () {
      expect(range.end.difference(range.start).inDays, 7);
    });

    test('contém o dia de referência', () {
      expect(range.contains(ref), isTrue);
    });

    test('não contém a semana seguinte', () {
      expect(range.contains(DateTime(2026, 6, 22)), isFalse);
    });
  });

  group('DateFilterUtils.rangeFor - mês', () {
    final ref = DateTime(2026, 6, 17);
    final range = DateFilterUtils.rangeFor(DateFilter.month, reference: ref);

    test('começa no primeiro dia do mês', () {
      expect(range.start, DateTime(2026, 6, 1));
    });

    test('termina no primeiro dia do mês seguinte', () {
      expect(range.end, DateTime(2026, 7, 1));
    });

    test('contém datas dentro do mês', () {
      expect(range.contains(DateTime(2026, 6, 30, 23)), isTrue);
    });

    test('não contém o mês seguinte', () {
      expect(range.contains(DateTime(2026, 7, 1)), isFalse);
    });
  });

  group('DateFilterUtils.relativeLabel', () {
    final ref = DateTime(2026, 6, 17, 12);

    test('hoje', () {
      expect(
        DateFilterUtils.relativeLabel(DateTime(2026, 6, 17, 8), reference: ref),
        'Hoje',
      );
    });

    test('ontem', () {
      expect(
        DateFilterUtils.relativeLabel(DateTime(2026, 6, 16, 8), reference: ref),
        'Ontem',
      );
    });
  });
}
