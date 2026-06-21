import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/primary_button.dart';
import '../../categories/domain/expense_category.dart';
import '../../categories/presentation/category_providers.dart';
import '../../categories/presentation/widgets/category_picker.dart';
import '../domain/expense.dart';
import '../domain/payment_method.dart';
import 'expense_form_controller.dart';
import 'widgets/amount_field.dart';

/// Formulário de criação e edição de gasto.
class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  /// Quando nulo, é um novo gasto; caso contrário, edição.
  final Expense? expense;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late final TextEditingController _note;

  String? _categoryId;
  PaymentMethod _paymentMethod = PaymentMethod.pix;
  late DateTime _date;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amount = TextEditingController(
      text: e != null ? _formatInitialAmount(e.amount) : '',
    );
    _description = TextEditingController(text: e?.description ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    _categoryId = e?.categoryId;
    _paymentMethod = e?.paymentMethod ?? PaymentMethod.pix;
    _date = e?.date ?? DateTime.now();
  }

  String _formatInitialAmount(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(
        () => _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  Future<void> _submit(List<ExpenseCategory> categories) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.tryParse(_amount.text);
    final amountError = Validators.amount(amount);
    if (amountError != null) {
      _showMessage(amountError);
      return;
    }
    if (_categoryId == null) {
      _showMessage('Escolha uma categoria.');
      return;
    }

    final category = categories.firstWhere((c) => c.id == _categoryId);
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(expenseFormControllerProvider.notifier)
        .save(
          id: widget.expense?.id,
          amount: amount!,
          description: _description.text,
          category: category,
          paymentMethod: _paymentMethod,
          date: _date,
          note: _note.text,
          createdAt: widget.expense?.createdAt,
        );

    if (!mounted) return;
    if (ok) {
      _showMessage(_isEditing ? 'Gasto atualizado.' : 'Gasto adicionado.');
      context.pop();
    } else {
      final error = ref.read(expenseFormControllerProvider).error;
      _showMessage(
        error is AppException ? error.message : 'Não foi possível salvar.',
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Excluir gasto',
      message: 'Tem certeza que deseja excluir este gasto?',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );
    if (!confirm) return;
    final ok = await ref
        .read(expenseFormControllerProvider.notifier)
        .delete(widget.expense!.id);
    if (!mounted) return;
    if (ok) {
      _showMessage('Gasto excluído.');
      context.pop();
    } else {
      _showMessage('Não foi possível excluir.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isSaving = ref.watch(expenseFormControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar gasto' : 'Novo gasto'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Excluir',
              onPressed: isSaving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const AppLoading(),
        error: (_, _) =>
            const AppError(message: 'Não foi possível carregar as categorias.'),
        data: (categories) => _buildForm(categories, isSaving),
      ),
    );
  }

  Widget _buildForm(List<ExpenseCategory> categories, bool isSaving) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AmountField(
                controller: _amount,
                autofocus: !_isEditing,
                validator: (value) {
                  final parsed = CurrencyFormatter.tryParse(value);
                  return Validators.amount(parsed);
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                validator: (v) =>
                    Validators.requiredField(v, label: 'uma descrição'),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              _Label('Categoria', theme),
              const SizedBox(height: AppConstants.spacingSm),
              CategoryPicker(
                categories: categories,
                selectedId: _categoryId,
                onSelected: (c) => setState(() => _categoryId = c.id),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              _Label('Forma de pagamento', theme),
              const SizedBox(height: AppConstants.spacingSm),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: PaymentMethod.values
                    .map(
                      (m) => DropdownMenuItem(value: m, child: Text(m.label)),
                    )
                    .toList(),
                onChanged: (m) =>
                    setState(() => _paymentMethod = m ?? _paymentMethod),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Data'),
                subtitle: Text(DateFilterUtils.formatDate(_date)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _pickDate,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _note,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  prefixIcon: Icon(Icons.sticky_note_2_outlined),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              PrimaryButton(
                label: _isEditing ? 'Salvar alterações' : 'Adicionar gasto',
                isLoading: isSaving,
                onPressed: () => _submit(categories),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.theme);
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
