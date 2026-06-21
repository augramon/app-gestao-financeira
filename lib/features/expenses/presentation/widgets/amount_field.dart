import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';

/// Campo de entrada de valor monetário (R$), com teclado numérico.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.validator,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      inputFormatters: [
        // Permite apenas dígitos, vírgula e ponto.
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: const InputDecoration(
        labelText: 'Valor',
        prefixText: '${AppConstants.currencySymbol} ',
        hintText: '0,00',
      ),
      validator: validator,
    );
  }
}
