import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/badge_delta.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/domain/expense_summary.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../expenses/presentation/widgets/expense_list_item.dart';
import '../../expenses/presentation/widgets/period_selector.dart';
import 'widgets/category_pie_chart.dart';

/// Dashboard inicial: saudação, período, total, resumo, gráfico e recentes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final summary = ref.watch(summaryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.expensesNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(expensesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingLg,
              AppConstants.spacingLg,
              96,
            ),
            children: [
              const _GreetingHeader(),
              const SizedBox(height: AppConstants.spacingLg),
              const PeriodSelector(),
              const SizedBox(height: AppConstants.spacingMd),
              _TotalCard(total: summary.totalAmount),
              const SizedBox(height: AppConstants.spacingSm),
              const _MonthComparisonRow(),
              const SizedBox(height: AppConstants.spacingMd),
              expensesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: AppLoading(),
                ),
                error: (_, _) => AppError(
                  message: 'Não foi possível carregar seus gastos.',
                  onRetry: () => ref.invalidate(expensesProvider),
                ),
                data: (expenses) => _DashboardContent(
                  summary: summary,
                  recent: expenses.take(5).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho do dashboard: saudação por horário, nome do usuário, avatar com
/// iniciais e uma frase animada (efeito máquina de escrever), sobre um fundo
/// sutil com leve gradiente — estilo app de gestão financeira.
class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  String _timeGreeting(int hour) {
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(appUserProvider).value;
    final name = user?.name ?? '';
    final firstName = user?.firstName ?? '';
    final greeting = _timeGreeting(DateTime.now().hour);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outline.withValues(alpha: isDark ? 0.25 : 0.12),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: isDark ? 0.22 : 0.10),
            colors.primary.withValues(alpha: isDark ? 0.04 : 0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstName.isNotEmpty ? firstName : 'Bem-vindo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              _AvatarBadge(initials: _initials(name)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          TypewriterText(
            phrases: const [
              'Seu resumo de gastos.',
              'Controle no seu ritmo.',
              'Saber gastar é poder.',
              'Pequenas economias contam.',
              'Cuide do seu futuro.',
            ],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar circular com as iniciais do usuário, preenchido com um gradiente
/// da cor primária.
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.18), colors.primary),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Métrica exibida no carrossel de resumo.
class _Metric {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

/// Carrossel horizontal de métricas em loop infinito: desliza sozinho,
/// continuamente, para o lado. Os cards são repetidos e o deslocamento volta
/// ao início a cada ciclo, criando um movimento sem emendas.
class _MetricsCarousel extends StatefulWidget {
  const _MetricsCarousel({required this.metrics});

  final List<_Metric> metrics;

  @override
  State<_MetricsCarousel> createState() => _MetricsCarouselState();
}

class _MetricsCarouselState extends State<_MetricsCarousel>
    with SingleTickerProviderStateMixin {
  final _controller = ScrollController();
  late final Ticker _ticker;
  Duration? _lastElapsed;

  // Largura do "slot" de cada card (160) + espaçamento (10).
  static const double _itemExtent = 170;
  static const double _speed = 45; // pixels por segundo

  double get _cycleWidth => _itemExtent * widget.metrics.length;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final last = _lastElapsed;
    _lastElapsed = elapsed;
    if (last == null || !_controller.hasClients) return;
    final dt = (elapsed - last).inMicroseconds / 1e6;
    var next = _controller.offset + _speed * dt;
    final cycle = _cycleWidth;
    if (cycle > 0 && next >= cycle) next -= cycle;
    _controller.jumpTo(next);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Repete os cards o suficiente para preencher a tela + um ciclo,
          // garantindo que o "wrap" do loop nunca deixe um vão visível.
          final repeats = (constraints.maxWidth / _cycleWidth).ceil() + 2;
          return SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                for (var r = 0; r < repeats; r++)
                  for (final m in widget.metrics)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: 160,
                        child: SummaryCard(
                          label: m.label,
                          value: m.value,
                          icon: m.icon,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total gasto no período',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              CurrencyFormatter.format(total),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Métrica de variação do gasto do mês atual em relação ao mês passado.
class _MonthComparisonRow extends ConsumerWidget {
  const _MonthComparisonRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comparison = ref.watch(monthComparisonProvider);
    final delta = comparison.deltaPercent;

    if (delta == null) {
      return Row(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Sem gastos no mês passado para comparar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final type = delta > 0
        ? BadgeDeltaType.increase
        : delta < 0
        ? BadgeDeltaType.decrease
        : BadgeDeltaType.neutral;
    final label = delta > 0
        ? 'a mais que o mês passado'
        : delta < 0
        ? 'a menos que o mês passado'
        : 'igual ao mês passado';

    return Row(
      children: [
        BadgeDelta(
          value: '${delta.abs().toStringAsFixed(1)}%',
          deltaType: type,
          variant: BadgeDeltaVariant.solid,
          higherIsBetter: false, // gastar mais é pior
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary, required this.recent});

  final ExpenseSummary summary;
  final List<Expense> recent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (summary.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: EmptyState(
          icon: Icons.insights_rounded,
          title: 'Sem gastos no período',
          message: 'Adicione um gasto para ver seu resumo e o gráfico.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carrossel horizontal de métricas com indicadores.
        _MetricsCarousel(
          metrics: [
            _Metric(
              label: 'Maior categoria',
              value: summary.highestCategoryName ?? '—',
              icon: Icons.local_fire_department_rounded,
            ),
            _Metric(
              label: 'Qtd. de gastos',
              value: '${summary.expenseCount}',
              icon: Icons.tag_rounded,
            ),
            _Metric(
              label: 'Gasto médio/dia',
              value: CurrencyFormatter.format(summary.dailyAverage),
              icon: Icons.today_rounded,
            ),
            _Metric(
              label: 'Maior valor',
              value: CurrencyFormatter.format(summary.highestCategoryAmount),
              icon: Icons.trending_up_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Text(
          'Gastos por categoria',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: CategoryPieChart(breakdown: summary.categoryBreakdown),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gastos recentes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        ...recent.map(
          (e) => ExpenseListItem(
            expense: e,
            showDate: true,
            onTap: () => context.push(AppRoutes.expenseEdit(e.id), extra: e),
          ),
        ),
      ],
    );
  }
}
