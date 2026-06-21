import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formatação de datas em PT-BR.
  await initializeDateFormatting('pt_BR');

  // Inicializa o Firebase. Requer `flutterfire configure` previamente.
  // Em caso de configuração ausente/placeholder, a app ainda abre na UI de
  // autenticação (degradação graciosa em vez de tela branca).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(
      'Falha ao inicializar o Firebase (rode "flutterfire configure"): $e',
    );
  }

  // Preferências locais (tema, onboarding).
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SpendlyApp(),
    ),
  );
}
