import 'package:intl/intl.dart';

/// Período de filtro disponível no app.
enum DateFilter { today, week, month, custom }

extension DateFilterLabel on DateFilter {
  String get label {
    switch (this) {
      case DateFilter.today:
        return 'Hoje';
      case DateFilter.week:
        return 'Semana';
      case DateFilter.month:
        return 'Mês';
      case DateFilter.custom:
        return 'Período';
    }
  }
}

/// Intervalo de datas inclusivo no início e exclusivo no fim.
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);
}

/// Lógica centralizada de cálculo de períodos e formatação de datas (PT-BR).
class DateFilterUtils {
  DateFilterUtils._();

  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _monthYear = DateFormat("MMMM 'de' yyyy", 'pt_BR');
  static final DateFormat _weekday = DateFormat('EEEE, dd/MM', 'pt_BR');

  /// Calcula o intervalo correspondente ao filtro a partir de [reference].
  ///
  /// Para [DateFilter.custom] informe [customStart] e [customEnd].
  static DateRange rangeFor(
    DateFilter filter, {
    DateTime? reference,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = reference ?? DateTime.now();
    switch (filter) {
      case DateFilter.today:
        final start = _startOfDay(now);
        return DateRange(start, start.add(const Duration(days: 1)));
      case DateFilter.week:
        // Semana começa na segunda-feira.
        final startOfWeek = _startOfDay(
          now.subtract(Duration(days: now.weekday - DateTime.monday)),
        );
        return DateRange(startOfWeek, startOfWeek.add(const Duration(days: 7)));
      case DateFilter.month:
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1);
        return DateRange(start, end);
      case DateFilter.custom:
        final start = _startOfDay(customStart ?? now);
        final end = _startOfDay(customEnd ?? now).add(const Duration(days: 1));
        return DateRange(start, end);
    }
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Formatação PT-BR.
  static String formatDate(DateTime date) => _dayMonthYear.format(date);
  static String formatMonth(DateTime date) => _monthYear.format(date);
  static String formatWeekday(DateTime date) => _weekday.format(date);

  /// Rótulo amigável e relativo para agrupamento de listas.
  static String relativeLabel(DateTime date, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final day = _startOfDay(date);
    final today = _startOfDay(now);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return formatDate(date);
  }
}
